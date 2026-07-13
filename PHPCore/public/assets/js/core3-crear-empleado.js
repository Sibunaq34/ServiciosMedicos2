(function () {
    // Busca la pantalla CORE3.
    const root = document.querySelector('[data-core3-crear-empleado]');

    if (!root) {
        return;
    }

    const textoNoRegistrado = 'No registrado';
    const textoNoDisponible = 'No disponible';
    const esperaSimuladaMs = 800;
    let oferenteActual = null;
    let enviando = false;

    const campos = {
        nombre: root.querySelector('[data-campo-nombre]'),
        identificacion: root.querySelector('[data-campo-identificacion]'),
        correo: root.querySelector('[data-campo-correo]'),
        telefono: root.querySelector('[data-campo-telefono]'),
        puesto: root.querySelector('[data-campo-puesto]'),
        fecha: root.querySelector('[data-campo-fecha]'),
        numero: root.querySelector('[data-campo-numero]'),
        estado: root.querySelector('[data-campo-estado]'),
        observaciones: root.querySelector('[data-campo-observaciones]'),
    };

    const errores = {
        nombre: root.querySelector('[data-error-nombre]'),
        identificacion: root.querySelector('[data-error-identificacion]'),
        puesto: root.querySelector('[data-error-puesto]'),
        fecha: root.querySelector('[data-error-fecha]'),
        numero: root.querySelector('[data-error-numero]'),
        estado: root.querySelector('[data-error-estado]'),
    };

    // Lee y valida el ID.
    function obtenerParametroId() {
        const id = root.dataset.oferenteId || '';
        return /^[1-9][0-9]*$/.test(id) ? Number(id) : null;
    }

    // Cambia el estado visual.
    function mostrarEstado(estado) {
        const estados = {
            parametroInvalido: root.querySelector('[data-parametro-invalido]'),
            carga: root.querySelector('[data-estado-carga]'),
            error: root.querySelector('[data-estado-error]'),
            vacio: root.querySelector('[data-estado-vacio]'),
            contenido: root.querySelector('[data-formulario-contenido]'),
        };

        Object.entries(estados).forEach(([clave, elemento]) => {
            if (elemento) {
                elemento.classList.toggle('d-none', clave !== estado);
            }
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

    function asignarTexto(selector, valor, respaldo) {
        const elemento = root.querySelector(selector);

        if (elemento) {
            elemento.textContent = textoSeguro(valor, respaldo);
        }
    }

    function primerElemento(lista) {
        return Array.isArray(lista) && lista.length > 0 ? textoSeguro(lista[0], textoNoDisponible) : textoNoDisponible;
    }

    // Genera numero demo.
    function generarNumeroEmpleadoSimulado(id) {
        const consecutivo = String(id).padStart(4, '0');
        return `EMP-2026-${consecutivo}`;
    }

    function construirUrlDetalle() {
        const id = obtenerParametroId();
        const url = new URL(root.dataset.detalleUrl, window.location.href);

        if (id !== null) {
            url.searchParams.set('id', String(id));
        }

        return `${url.pathname.split('/').pop()}${url.search}`;
    }

    // Vuelve a CORE9.
    function configurarCancelacion() {
        const destino = construirUrlDetalle();

        root.querySelectorAll('[data-cancelar-superior], [data-cancelar-formulario]').forEach((enlace) => {
            enlace.href = destino;
        });
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

    // Revisa datos minimos.
    function validarEstructuraOferente(oferente) {
        return oferente !== null
            && typeof oferente === 'object'
            && Number.isInteger(oferente.id)
            && typeof oferente.nombreCompleto === 'string'
            && typeof oferente.identificacion === 'string';
    }

    // Llena opciones de puesto.
    function llenarPuestos(oferente) {
        if (!campos.puesto) {
            return;
        }

        const puestoPrincipal = textoSeguro(oferente.puestoPostulado?.nombre, '');
        const puestos = [
            puestoPrincipal,
            'Enfermero',
            'Recepcionista',
            'Asistente administrativa',
        ].filter((puesto, indice, lista) => puesto && lista.indexOf(puesto) === indice);

        puestos.forEach((puesto) => {
            const opcion = document.createElement('option');
            opcion.value = puesto;
            opcion.textContent = puesto;
            campos.puesto.appendChild(opcion);
        });

        if (puestoPrincipal) {
            campos.puesto.value = puestoPrincipal;
        }
    }

    // Muestra datos del oferente.
    function renderizarFormulario(oferente) {
        const correo = primerElemento(oferente.correos);
        const telefono = primerElemento(oferente.telefonos);
        const numeroEmpleado = generarNumeroEmpleadoSimulado(oferente.id);

        asignarTexto('[data-resumen-nombre]', oferente.nombreCompleto, textoNoRegistrado);
        asignarTexto('[data-resumen-identificacion]', oferente.identificacion, textoNoRegistrado);
        asignarTexto('[data-resumen-correo]', correo, textoNoDisponible);
        asignarTexto('[data-resumen-telefono]', telefono, textoNoDisponible);

        campos.nombre.value = textoSeguro(oferente.nombreCompleto, '');
        campos.identificacion.value = textoSeguro(oferente.identificacion, '');
        campos.correo.value = correo === textoNoDisponible ? '' : correo;
        campos.telefono.value = telefono === textoNoDisponible ? '' : telefono;
        campos.numero.value = numeroEmpleado;
        campos.estado.value = 'En induccion';

        llenarPuestos(oferente);
    }

    // Limpia errores previos.
    function limpiarMensajes() {
        Object.values(errores).forEach((elemento) => {
            if (elemento) {
                elemento.textContent = '';
            }
        });

        root.querySelector('[data-mensaje-exito]')?.classList.add('d-none');
        root.querySelector('[data-mensaje-error]')?.classList.add('d-none');
    }

    function asignarError(campo, mensaje) {
        if (errores[campo]) {
            errores[campo].textContent = mensaje;
        }
    }

    function fechaValida(valor) {
        if (!/^\d{4}-\d{2}-\d{2}$/.test(valor)) {
            return false;
        }

        const fecha = new Date(`${valor}T00:00:00`);
        return !Number.isNaN(fecha.getTime());
    }

    // Valida antes de simular.
    function validarFormulario() {
        limpiarMensajes();

        const datos = {
            idOferente: oferenteActual?.id,
            nombre: campos.nombre.value.trim(),
            identificacion: campos.identificacion.value.trim(),
            correo: campos.correo.value.trim(),
            telefono: campos.telefono.value.trim(),
            puesto: campos.puesto.value.trim(),
            fechaContratacion: campos.fecha.value.trim(),
            numeroEmpleado: campos.numero.value.trim(),
            estado: campos.estado.value.trim(),
            observaciones: campos.observaciones.value.trim(),
        };

        let valido = true;

        if (!oferenteActual || !Number.isInteger(datos.idOferente)) {
            valido = false;
            asignarError('nombre', 'El oferente seleccionado no es valido.');
        }

        if (!datos.nombre) {
            valido = false;
            asignarError('nombre', 'El nombre del oferente es requerido.');
        }

        if (!datos.identificacion) {
            valido = false;
            asignarError('identificacion', 'La identificacion del oferente es requerida.');
        }

        if (!datos.puesto) {
            valido = false;
            asignarError('puesto', 'Seleccione el puesto del empleado.');
        }

        if (!datos.fechaContratacion) {
            valido = false;
            asignarError('fecha', 'La fecha de contratacion es requerida.');
        } else if (!fechaValida(datos.fechaContratacion)) {
            valido = false;
            asignarError('fecha', 'Ingrese una fecha de contratacion valida.');
        }

        if (!datos.numeroEmpleado) {
            valido = false;
            asignarError('numero', 'No se pudo generar el numero provisional.');
        }

        if (!datos.estado) {
            valido = false;
            asignarError('estado', 'Seleccione el estado inicial del empleado.');
        }

        return {
            valido,
            datos,
        };
    }

    // Evita doble clic.
    function establecerCargaConfirmacion(cargando) {
        const boton = root.querySelector('[data-boton-confirmar]');
        const spinner = root.querySelector('[data-spinner-confirmar]');

        if (boton) {
            boton.disabled = cargando;
        }

        if (spinner) {
            spinner.classList.toggle('d-none', !cargando);
        }
    }

    function esperar(ms) {
        return new Promise((resolve) => {
            window.setTimeout(resolve, ms);
        });
    }

    // Simula creacion sin guardar.
    async function simularCreacionEmpleado(datosEmpleado) {
        await esperar(esperaSimuladaMs);

        if (root.dataset.simularError === '1') {
            throw new Error('Error simulado de creacion.');
        }

        return {
            correcto: true,
            numeroEmpleado: datosEmpleado.numeroEmpleado,
        };
    }

    // Maneja confirmar creacion.
    async function manejarConfirmacion(evento) {
        evento.preventDefault();

        if (enviando) {
            return;
        }

        const resultadoValidacion = validarFormulario();

        if (!resultadoValidacion.valido) {
            return;
        }

        enviando = true;
        establecerCargaConfirmacion(true);

        try {
            const resultado = await simularCreacionEmpleado(resultadoValidacion.datos);

            if (!resultado.correcto) {
                throw new Error('Respuesta simulada invalida.');
            }

            root.querySelector('[data-mensaje-exito]')?.classList.remove('d-none');
        } catch (error) {
            console.error(error);
            root.querySelector('[data-mensaje-error]')?.classList.remove('d-none');
        } finally {
            enviando = false;
            establecerCargaConfirmacion(false);
        }
    }

    // Flujo principal CORE3.
    async function cargarDatosParaCrearEmpleado() {
        const id = obtenerParametroId();
        configurarCancelacion();

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

            oferenteActual = oferente;
            renderizarFormulario(oferente);
            mostrarEstado('contenido');
        } catch (error) {
            console.error(error);
            mostrarEstado('error');
        } finally {
            root.querySelector('[data-estado-carga]')?.classList.add('d-none');
        }
    }

    root.querySelector('[data-formulario-empleado]')?.addEventListener('submit', manejarConfirmacion);
    cargarDatosParaCrearEmpleado();
}());
