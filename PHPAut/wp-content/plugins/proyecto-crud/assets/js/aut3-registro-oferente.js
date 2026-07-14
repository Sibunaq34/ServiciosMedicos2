(function () {
    'use strict';

    function inicializarRegistro(root) {
        const form = root.querySelector('[data-aut3-form]');
        const modal = root.querySelector('[data-aut3-modal]');
        const cancelar = root.querySelector('[data-aut3-cancelar]');
        const modalAceptar = root.querySelector('[data-aut3-modal-aceptar]');

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

        // Persona C - Kenneth
        // Validaciones visuales temporales.
        function validarIdentificacion() {
            const identificacion = String(form.elements.identificacion.value || '').trim();

            // Persona C - Kenneth
            // Regla especifica por tipo pendiente de confirmacion con el equipo.
            // No se infiere el formato a partir de datos de prueba.
            if (!identificacion || identificacion.length > 30) {
                setError('identificacion', 'Ingrese una identificaci\u00f3n v\u00e1lida.');
                return false;
            }

            setError('identificacion', '');
            return true;
        }

        function validarCorreos() {
            const correos = valoresSeparadosPorComas(form.elements.correos.value);
            const patronCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const invalido = correos.find((correo) => !patronCorreo.test(correo));

            setError('correos', invalido ? 'Ingrese correos con formato v\u00e1lido separados por comas.' : '');
            return !invalido;
        }

        function validarTelefonos() {
            const telefonos = valoresSeparadosPorComas(form.elements.telefonos.value);
            const patronTelefono = /^[0-9+(). -]{7,20}$/;
            const invalido = telefonos.find((telefono) => !patronTelefono.test(telefono));

            if (telefonos.length === 0) {
                setError('telefonos', 'Ingrese al menos un tel\u00e9fono v\u00e1lido.');
                return false;
            }

            setError('telefonos', invalido ? 'Ingrese tel\u00e9fonos v\u00e1lidos separados por comas.' : '');
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
                validarRequerido('tipo_identificacion', 'Seleccione el tipo de identificaci\u00f3n.'),
                validarIdentificacion(),
                validarRequerido('nombre_completo', 'Ingrese el nombre completo.'),
                validarRequerido('fecha_nacimiento', 'Indique la fecha de nacimiento.'),
                validarCorreos(),
                validarTelefonos(),
                validarCurriculum(),
            ];

            return validaciones.every(Boolean);
        }

        // Persona C - Kenneth
        // Modal temporal sin persistencia real.
        function mostrarModal() {
            modal.hidden = false;
            modalAceptar.focus();
        }

        form.addEventListener('submit', (event) => {
            event.preventDefault();

            // Persona C - Kenneth
            // Persistencia temporalmente pendiente.
            // Sustituir por el repository y las tablas principales cuando sean confirmados.
            if (validarFormulario()) {
                mostrarModal();
            }
        });

        cancelar.addEventListener('click', volver);
        modalAceptar.addEventListener('click', volver);
    }

    document.querySelectorAll('[data-aut3-registro-oferente]').forEach(inicializarRegistro);
}());
