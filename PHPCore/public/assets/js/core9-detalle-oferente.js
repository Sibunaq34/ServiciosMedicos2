(function () {
    // Busca la pantalla CORE9.
    const root = document.querySelector('[data-core9-detalle]');

    if (!root) {
        return;
    }

    const selectors = {
        parametroInvalido: '[data-parametro-invalido]',
        carga: '[data-estado-carga]',
        error: '[data-estado-error]',
        vacio: '[data-estado-vacio]',
        contenido: '[data-detalle-contenido]',
        crearEmpleado: '[data-crear-empleado]',
    };

    const textoNoRegistrado = 'No registrado';
    const textoNoDisponible = 'No disponible';
    const textoSinInformacion = 'No hay informacion registrada.';

    // Lee y valida el ID.
    function obtenerParametroId() {
        const id = root.dataset.oferenteId || '';
        return /^[1-9][0-9]*$/.test(id) ? Number(id) : null;
    }

    // Cambia el estado visual.
    function mostrarEstado(estado) {
        const estados = {
            parametroInvalido: root.querySelector(selectors.parametroInvalido),
            carga: root.querySelector(selectors.carga),
            error: root.querySelector(selectors.error),
            vacio: root.querySelector(selectors.vacio),
            contenido: root.querySelector(selectors.contenido),
        };

        Object.entries(estados).forEach(([clave, elemento]) => {
            if (!elemento) {
                return;
            }


            elemento.classList.toggle('d-none', clave !== estado);
        });
    }

    // Evita valores vacios.
    function textoSeguro(valor, respaldo = textoNoRegistrado) {
        if (typeof valor !== 'string' && typeof valor !== 'number') {
            return respaldo;
        }

        const texto = String(valor).trim();
        return texto.length > 0 ? texto : respaldo;
    }

    // Muestra fechas legibles.
    function formatearFecha(valor) {
        const texto = textoSeguro(valor, '');

        if (!/^\d{4}-\d{2}-\d{2}$/.test(texto)) {
            return textoNoRegistrado;
        }

        const fecha = new Date(`${texto}T00:00:00`);

        if (Number.isNaN(fecha.getTime())) {
            return textoNoRegistrado;
        }

        return fecha.toLocaleDateString('es-CR', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
        });
    }

    function formatearPeriodo(inicio, fin) {
        const fechaInicio = formatearFecha(inicio);
        const fechaFin = formatearFecha(fin);

        if (fechaInicio === textoNoRegistrado && fechaFin === textoNoRegistrado) {
            return textoNoRegistrado;
        }

        return `${fechaInicio} - ${fechaFin === textoNoRegistrado ? 'Actual' : fechaFin}`;
    }

    function asignarTexto(selector, valor, respaldo) {
        const elemento = root.querySelector(selector);

        if (elemento) {
            elemento.textContent = textoSeguro(valor, respaldo);
        }
    }

    function limpiarElemento(elemento) {
        while (elemento.firstChild) {
            elemento.removeChild(elemento.firstChild);
        }
    }

    // Pinta listas seguras.
    function renderizarLista(selector, elementos) {
        const lista = root.querySelector(selector);

        if (!lista) {
            return;
        }

        limpiarElemento(lista);

        if (!Array.isArray(elementos) || elementos.length === 0) {
            const item = document.createElement('li');
            item.className = 'text-secondary';
            item.textContent = textoSinInformacion;
            lista.appendChild(item);
            return;
        }

        elementos.forEach((valor) => {
            const item = document.createElement('li');
            item.textContent = textoSeguro(valor, textoNoDisponible);
            lista.appendChild(item);
        });
    }

    // Pinta tablas seguras.
    function renderizarTabla(selector, filas, columnas) {
        const cuerpo = root.querySelector(selector);

        if (!cuerpo) {
            return;
        }

        limpiarElemento(cuerpo);

        if (!Array.isArray(filas) || filas.length === 0) {
            const fila = document.createElement('tr');
            const celda = document.createElement('td');
            celda.colSpan = columnas.length;
            celda.className = 'text-secondary';
            celda.textContent = textoSinInformacion;
            fila.appendChild(celda);
            cuerpo.appendChild(fila);
            return;
        }

        filas.forEach((registro) => {
            const fila = document.createElement('tr');

            columnas.forEach((columna) => {
                const celda = document.createElement('td');
                celda.textContent = columna(registro);
                fila.appendChild(celda);
            });

            cuerpo.appendChild(fila);
        });
    }

    // Revisa datos minimos.
    function validarEstructuraOferente(oferente) {
        return oferente !== null
            && typeof oferente === 'object'
            && Number.isInteger(oferente.id)
            && typeof oferente.nombreCompleto === 'string'
            && typeof oferente.identificacion === 'string';
    }

    // Consulta JSON local.
    async function obtenerOferentes() {
        const respuesta = await fetch(root.dataset.jsonUrl, {
            method: 'GET',
            headers: {
                Accept: 'application/json',
            },
        });

        if (!respuesta.ok) {
            throw new Error('No se pudo cargar el archivo de oferentes.');
        }

        const datos = await respuesta.json();

        if (!Array.isArray(datos)) {
            throw new Error('La estructura del JSON de oferentes no es valida.');
        }

        return datos;
    }

    // Busca oferente por ID.
    async function obtenerOferentePorId(id) {
        const oferentes = await obtenerOferentes();
        return oferentes.find((oferente) => Number(oferente.id) === id) || null;
    }

    // Muestra el detalle.
    function renderizarDetalle(oferente) {
        asignarTexto('[data-estado]', oferente.estado, textoNoDisponible);
        asignarTexto('[data-nombre]', oferente.nombreCompleto, textoNoRegistrado);
        asignarTexto('[data-tipo-identificacion]', oferente.tipoIdentificacion, textoNoRegistrado);
        asignarTexto('[data-identificacion]', oferente.identificacion, textoNoRegistrado);
        asignarTexto('[data-fecha-nacimiento]', formatearFecha(oferente.fechaNacimiento), textoNoRegistrado);
        asignarTexto('[data-direccion]', oferente.direccion, textoNoRegistrado);
        asignarTexto('[data-puesto-postulado]', oferente.puestoPostulado?.nombre, textoNoDisponible);
        asignarTexto('[data-concurso]', oferente.concurso?.nombre, textoNoDisponible);

        renderizarLista('[data-correos]', oferente.correos);
        renderizarLista('[data-telefonos]', oferente.telefonos);
        renderizarLista('[data-requisitos]', oferente.requisitosCumplidos);

        renderizarTabla('[data-preparacion-academica]', oferente.preparacionAcademica, [
            (registro) => textoSeguro(registro?.institucion, textoNoDisponible),
            (registro) => textoSeguro(registro?.titulo, textoNoDisponible),
            (registro) => formatearPeriodo(registro?.fechaInicio, registro?.fechaFin),
        ]);

        renderizarTabla('[data-experiencia-laboral]', oferente.experienciaLaboral, [
            (registro) => textoSeguro(registro?.empresa, textoNoDisponible),
            (registro) => textoSeguro(registro?.puesto, textoNoDisponible),
            (registro) => formatearPeriodo(registro?.fechaInicio, registro?.fechaFin),
        ]);

        const crearEmpleado = root.querySelector(selectors.crearEmpleado);

        if (crearEmpleado) {
            const url = new URL(root.dataset.crearEmpleadoUrl, window.location.href);
            url.searchParams.set('idOferente', String(oferente.id));
            crearEmpleado.href = `${url.pathname.split('/').pop()}${url.search}`;
        }
    }

    // Flujo principal CORE9.
    async function cargarDetalleOferente() {
        const id = obtenerParametroId();

        if (id === null) {
            mostrarEstado('parametroInvalido');
            return;
        }

        mostrarEstado('carga');

        try {
            const oferente = await obtenerOferentePorId(id);

            if (!oferente) {
                mostrarEstado('vacio');
                return;
            }

            if (!validarEstructuraOferente(oferente)) {
                throw new Error('El registro del oferente esta incompleto.');
            }

            renderizarDetalle(oferente);
            mostrarEstado('contenido');
        } catch (error) {
            console.error(error);
            mostrarEstado('error');
        } finally {
            const carga = root.querySelector(selectors.carga);

            if (carga) {
                carga.classList.add('d-none');
            }
        }
    }

    cargarDetalleOferente();
}());
