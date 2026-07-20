(function () {
    'use strict';

    function inicializarRegistro(root) {
        const form = root.querySelector('[data-aut3-form]');
        const modal = root.querySelector('[data-aut3-modal]');
        const cancelar = root.querySelector('[data-aut3-cancelar]');
        const modalAceptar = root.querySelector('[data-aut3-modal-aceptar]');
        const modalMensaje = root.querySelector('[data-aut3-modal-mensaje]');
        const serverMessage = root.querySelector('[data-aut3-server-message]');
        const submitButton = form ? form.querySelector('[type="submit"]') : null;
        let enviando = false;

        if (!form || !modal || !cancelar || !modalAceptar) {
            return;
        }

        // Persona C - Kenneth
        // Navegacion de retorno a AUT2.
        function obtenerUrlRetorno() {
            return root.dataset.urlRetorno || document.referrer || window.location.href;
        }

        function volver() {
            window.location.assign(obtenerUrlRetorno());
        }

        function valoresSeparadosPorComas(valor) {
            return String(valor || '')
                .split(',')
                .map((item) => item.trim())
                .filter(Boolean);
        }

        function eliminarDuplicados(valores, obtenerClave) {
            const claves = new Set();

            return valores.filter((valor) => {
                const clave = obtenerClave(valor);

                if (claves.has(clave)) {
                    return false;
                }

                claves.add(clave);
                return true;
            });
        }

        function setError(nombre, mensaje) {
            const campo = form.elements[nombre];
            const error = root.querySelector(`[data-error-for="${nombre}"]`);

            if (campo) {
                campo.setAttribute('aria-invalid', mensaje ? 'true' : 'false');
            }

            if (error) {
                error.textContent = mensaje;
            }
        }

        function setMensajeServidor(mensaje, exito) {
            if (!serverMessage) {
                return;
            }

            serverMessage.textContent = mensaje || '';
            serverMessage.style.color = exito ? 'CanvasText' : '#b42318';
        }

        function limpiarErroresServidor() {
            ['codigo_puesto', 'tipo_identificacion', 'identificacion', 'nombre_completo', 'fecha_nacimiento', 'correos', 'telefonos', 'curriculum'].forEach((nombre) => {
                setError(nombre, '');
            });
            setMensajeServidor('', false);
        }

        // Persona C - Kenneth
        // Validaciones visuales del formulario.
        function validarTipoIdentificacion() {
            const tipo = form.elements.tipo_identificacion.value;
            const valido = ['CedulaIdentidad', 'DIMEX', 'Pasaporte'].includes(tipo);

            setError('tipo_identificacion', valido ? '' : 'Seleccione el tipo de identificaci\u00f3n.');
            return valido;
        }

        function normalizarIdentificacion(identificacion, tipo) {
            const valor = String(identificacion || '').trim();

            // Persona C - Kenneth
            // Normaliza la identificacion segun las reglas reutilizadas de OFE1.
            if (tipo === 'CedulaIdentidad' || tipo === 'DIMEX') {
                return valor.replace(/[\s-]+/g, '');
            }

            return valor;
        }

        function validarIdentificacion() {
            const campo = form.elements.identificacion;
            const tipo = form.elements.tipo_identificacion.value;
            const identificacionOriginal = String(campo.value || '').trim();
            const identificacion = normalizarIdentificacion(identificacionOriginal, tipo);

            if (!identificacion || identificacion.length > 30) {
                setError('identificacion', 'Ingrese una identificaci\u00f3n v\u00e1lida.');
                return false;
            }

            campo.value = identificacion;

            if (tipo === 'CedulaIdentidad' && !/^[0-9]{9}$/.test(identificacion)) {
                setError('identificacion', 'La c\u00e9dula debe contener exactamente 9 d\u00edgitos num\u00e9ricos.');
                return false;
            }

            if (tipo === 'DIMEX' && !/^[0-9]{11,12}$/.test(identificacion)) {
                setError('identificacion', 'El DIMEX debe contener entre 11 y 12 d\u00edgitos num\u00e9ricos.');
                return false;
            }

            if (tipo === 'Pasaporte' && !/^[A-Za-z0-9]{6,20}$/.test(identificacion)) {
                setError('identificacion', 'El pasaporte debe contener entre 6 y 20 caracteres alfanum\u00e9ricos.');
                return false;
            }

            setError('identificacion', '');
            return true;
        }

        function validarNombreCompleto() {
            const campo = form.elements.nombre_completo;
            const nombre = String(campo.value || '').trim();
            const patronNombre = /^[A-Za-z\u00c1\u00c9\u00cd\u00d3\u00da\u00e1\u00e9\u00ed\u00f3\u00fa\u00d1\u00f1\u00dc\u00fc\s]+$/;

            campo.value = nombre;

            if (!nombre) {
                setError('nombre_completo', 'Ingrese el nombre completo.');
                return false;
            }

            if (nombre.length > 150 || !patronNombre.test(nombre)) {
                setError('nombre_completo', 'El nombre completo solo puede contener letras y espacios.');
                return false;
            }

            setError('nombre_completo', '');
            return true;
        }

        function validarFechaNacimiento() {
            const campo = form.elements.fecha_nacimiento;
            const valido = Boolean(campo && campo.value && campo.validity.valid);

            setError('fecha_nacimiento', valido ? '' : 'Indique la fecha de nacimiento.');
            return valido;
        }

        function validarCorreos() {
            const campo = form.elements.correos;
            const correos = eliminarDuplicados(
                valoresSeparadosPorComas(campo.value),
                (correo) => correo.toLowerCase()
            );
            const patronCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const invalido = correos.find((correo) => !patronCorreo.test(correo));

            campo.value = correos.join(', ');

            if (correos.length === 0) {
                setError('correos', 'Debe indicar al menos un correo electr\u00f3nico.');
                return false;
            }

            setError('correos', invalido ? 'Ingrese correos con formato v\u00e1lido separados por comas.' : '');
            return !invalido;
        }

        function validarTelefonos() {
            const campo = form.elements.telefonos;
            const telefonos = eliminarDuplicados(
                valoresSeparadosPorComas(campo.value),
                (telefono) => telefono
            );
            const patronTelefono = /^[0-9]{8}$/;
            const invalido = telefonos.find((telefono) => !patronTelefono.test(telefono));

            campo.value = telefonos.join(', ');

            if (telefonos.length === 0) {
                setError('telefonos', 'Debe indicar al menos un tel\u00e9fono.');
                return false;
            }

            setError('telefonos', invalido ? 'El tel\u00e9fono debe contener exactamente 8 d\u00edgitos num\u00e9ricos.' : '');
            return !invalido;
        }

        function validarCurriculum() {
            const archivo = form.elements.curriculum.files[0];

            if (!archivo) {
                setError('curriculum', 'Adjunte el curr\u00edculum.');
                return false;
            }

            setError('curriculum', '');
            return true;
        }

        function validarRequerido(nombre, mensaje) {
            const campo = form.elements[nombre];
            const valido = Boolean(campo && String(campo.value || '').trim());

            setError(nombre, valido ? '' : mensaje);
            return valido;
        }

        function validarFormulario() {
            const validaciones = [
                validarTipoIdentificacion(),
                validarIdentificacion(),
                validarNombreCompleto(),
                validarFechaNacimiento(),
                validarCorreos(),
                validarTelefonos(),
                validarCurriculum(),
            ];

            return validaciones.every(Boolean);
        }

        // Persona C - Kenneth
        // Modal de confirmacion tras persistencia real.
        function mostrarModal(mensaje) {
            if (modalMensaje && mensaje) {
                modalMensaje.textContent = mensaje;
            }

            modal.hidden = false;
            modalAceptar.focus();
        }

        function aplicarErroresServidor(errores) {
            Object.entries(errores || {}).forEach(([nombre, mensaje]) => {
                setError(nombre, mensaje);
            });
        }

        function cambiarEstadoEnvio(activo) {
            enviando = activo;

            if (submitButton) {
                submitButton.disabled = activo;
                submitButton.textContent = activo ? 'Guardando...' : 'Aceptar';
            }
        }

        async function enviarFormulario() {
            const config = window.AUT3RegistroOferente || {};
            const formData = new FormData(form);

            if (!formData.get('nonce') && config.nonce) {
                formData.append('nonce', config.nonce);
            }

            const response = await fetch(config.ajaxUrl || form.action, {
                method: 'POST',
                body: formData,
                credentials: 'same-origin',
            });

            const payload = await response.json();

            if (!response.ok || !payload.success) {
                const data = payload.data || {};
                aplicarErroresServidor(data.errores || {});
                throw new Error(data.mensaje || 'No fue posible completar el registro.');
            }

            return payload.data || {};
        }

        form.addEventListener('submit', (event) => {
            event.preventDefault();

            // Persona C - Kenneth
            // Envia el formulario solo despues de validar en cliente.
            if (enviando) {
                return;
            }

            limpiarErroresServidor();

            if (!validarFormulario()) {
                return;
            }

            cambiarEstadoEnvio(true);

            enviarFormulario()
                .then((data) => {
                    setMensajeServidor('', true);
                    mostrarModal(data.mensaje || 'Datos guardados de manera satisfactoria');
                })
                .catch((error) => {
                    setMensajeServidor(error.message, false);
                })
                .finally(() => {
                    cambiarEstadoEnvio(false);
                });
        });

        cancelar.addEventListener('click', volver);
        modalAceptar.addEventListener('click', volver);
    }

    document.querySelectorAll('[data-aut3-registro-oferente]').forEach(inicializarRegistro);
}());
