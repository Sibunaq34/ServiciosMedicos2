<?php

require_once plugin_dir_path(__DIR__) . 'repository/RegistroOferenteRepository.php';

class RegistroOferenteService
{
    private const TAMANIO_MAXIMO_CURRICULUM = 5242880;

    private RegistroOferenteRepository $repository;

    public function __construct(?RegistroOferenteRepository $repository = null)
    {
        $this->repository = $repository ?: new RegistroOferenteRepository();
    }

    public function obtenerPuestoActivo(string $codigoPuesto): ?array
    {
        return $this->repository->obtenerPuestoActivoPorCodigo($codigoPuesto);
    }

    public function registrar(array $entrada, ?array $archivo): array
    {
        // Persona C - Kenneth
        // Valida y normaliza los datos del registro externo.
        $errores = [];
        $datos = [
            'tipo_identificacion' => $this->texto($entrada['tipo_identificacion'] ?? ''),
            'identificacion' => $this->texto($entrada['identificacion'] ?? ''),
            'nombre_completo' => $this->texto($entrada['nombre_completo'] ?? ''),
            'fecha_nacimiento' => $this->texto($entrada['fecha_nacimiento'] ?? ''),
            'codigo_puesto' => $this->texto($entrada['codigo_puesto'] ?? ''),
            'correos' => $this->listaSeparadaPorComas($entrada['correos'] ?? ''),
            'telefonos' => $this->listaSeparadaPorComas($entrada['telefonos'] ?? ''),
        ];

        $this->validarTipoIdentificacion($datos, $errores);
        $this->validarIdentificacion($datos, $errores);
        $this->validarNombre($datos, $errores);
        $this->validarFecha($datos, $errores);
        $this->validarCorreos($datos, $errores);
        $this->validarTelefonos($datos, $errores);
        $puesto = $this->validarPuesto($datos, $errores);

        if ($this->repository->existeIdentificacion($datos['identificacion'])) {
            $errores['identificacion'] = 'La identificación indicada ya se encuentra registrada.';
        }

        $validacionArchivo = $this->validarCurriculum($archivo);

        if (!$validacionArchivo['exito']) {
            $errores['curriculum'] = $validacionArchivo['mensaje'];
        }

        if ($errores) {
            return $this->fallo('Revise los datos del formulario.', $errores);
        }

        $curriculum = $this->guardarCurriculum($archivo, $validacionArchivo['mime']);

        if (!$curriculum['exito']) {
            return $this->fallo($curriculum['mensaje'], ['curriculum' => $curriculum['mensaje']]);
        }

        $datos['curriculum'] = $curriculum['datos'];
        $resultado = $this->repository->registrar($datos);

        if (!$resultado['exito']) {
            $this->eliminarCurriculum($datos['curriculum']['archivo']);

            return $this->fallo($resultado['mensaje']);
        }

        return [
            'exito' => true,
            'mensaje' => 'Datos guardados de manera satisfactoria',
            'errores' => [],
            'datos' => [
                'puesto' => $puesto,
                'registro' => $resultado['datos'],
            ],
        ];
    }

    private function validarTipoIdentificacion(array $datos, array &$errores): void
    {
        if (!in_array($datos['tipo_identificacion'], ['CedulaIdentidad', 'DIMEX', 'Pasaporte'], true)) {
            $errores['tipo_identificacion'] = 'Seleccione el tipo de identificación.';
        }
    }

    private function validarIdentificacion(array &$datos, array &$errores): void
    {
        if ($datos['tipo_identificacion'] === 'CedulaIdentidad' || $datos['tipo_identificacion'] === 'DIMEX') {
            $datos['identificacion'] = preg_replace('/[\s-]+/', '', $datos['identificacion']);
        }

        if ($datos['identificacion'] === '' || strlen($datos['identificacion']) > 30) {
            $errores['identificacion'] = 'Ingrese una identificación válida.';
            return;
        }

        if ($datos['tipo_identificacion'] === 'CedulaIdentidad' && !preg_match('/^[0-9]{9}$/', $datos['identificacion'])) {
            $errores['identificacion'] = 'La cédula debe contener exactamente 9 dígitos numéricos.';
        }

        if ($datos['tipo_identificacion'] === 'DIMEX' && !preg_match('/^[0-9]{11,12}$/', $datos['identificacion'])) {
            $errores['identificacion'] = 'El DIMEX debe contener entre 11 y 12 dígitos numéricos.';
        }

        if ($datos['tipo_identificacion'] === 'Pasaporte' && !preg_match('/^[A-Za-z0-9]{6,20}$/', $datos['identificacion'])) {
            $errores['identificacion'] = 'El pasaporte debe contener entre 6 y 20 caracteres alfanuméricos.';
        }
    }

    private function validarNombre(array $datos, array &$errores): void
    {
        if ($datos['nombre_completo'] === '') {
            $errores['nombre_completo'] = 'Ingrese el nombre completo.';
            return;
        }

        if (mb_strlen($datos['nombre_completo']) > 150 || !preg_match('/^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s]+$/u', $datos['nombre_completo'])) {
            $errores['nombre_completo'] = 'El nombre completo solo puede contener letras y espacios.';
        }
    }

    private function validarFecha(array $datos, array &$errores): void
    {
        $fecha = DateTime::createFromFormat('Y-m-d', $datos['fecha_nacimiento']);

        if (!$fecha || $fecha->format('Y-m-d') !== $datos['fecha_nacimiento']) {
            $errores['fecha_nacimiento'] = 'Indique la fecha de nacimiento.';
        }
    }

    private function validarCorreos(array &$datos, array &$errores): void
    {
        if (!$datos['correos']) {
            $errores['correos'] = 'Debe indicar al menos un correo electrónico.';
            return;
        }

        if ($this->tieneDuplicados($datos['correos'], static fn (string $correo): string => strtolower($correo))) {
            $errores['correos'] = 'No se deben repetir correos.';
            return;
        }

        foreach ($datos['correos'] as $correo) {
            if (!is_email($correo)) {
                $errores['correos'] = 'Ingrese correos con formato válido separados por comas.';
                return;
            }
        }
    }

    private function validarTelefonos(array &$datos, array &$errores): void
    {
        if (!$datos['telefonos']) {
            $errores['telefonos'] = 'Debe indicar al menos un teléfono.';
            return;
        }

        if ($this->tieneDuplicados($datos['telefonos'], static fn (string $telefono): string => $telefono)) {
            $errores['telefonos'] = 'No se deben repetir teléfonos.';
            return;
        }

        foreach ($datos['telefonos'] as $telefono) {
            if (!preg_match('/^[0-9]{8}$/', $telefono)) {
                $errores['telefonos'] = 'El teléfono debe contener exactamente 8 dígitos numéricos.';
                return;
            }
        }
    }

    private function validarPuesto(array $datos, array &$errores): ?array
    {
        if ($datos['codigo_puesto'] === '') {
            $errores['codigo_puesto'] = 'Seleccione un puesto disponible.';
            return null;
        }

        $puesto = $this->repository->obtenerPuestoActivoPorCodigo($datos['codigo_puesto']);

        if (!$puesto) {
            $errores['codigo_puesto'] = 'El puesto seleccionado no existe o ya no está disponible.';
            return null;
        }

        return $puesto;
    }

    private function validarCurriculum(?array $archivo): array
    {
        if (!$archivo || !isset($archivo['error']) || (int) $archivo['error'] === UPLOAD_ERR_NO_FILE) {
            return $this->resultadoArchivo(false, 'Adjunte el currículum.');
        }

        if ((int) $archivo['error'] !== UPLOAD_ERR_OK) {
            return $this->resultadoArchivo(false, 'No fue posible cargar el currículum.');
        }

        if ((int) $archivo['size'] <= 0 || (int) $archivo['size'] > self::TAMANIO_MAXIMO_CURRICULUM) {
            return $this->resultadoArchivo(false, 'El currículum no debe superar 5 MB.');
        }

        $mime = $this->mimeReal($archivo['tmp_name']);
        $permitidos = [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ];

        if (!in_array($mime, $permitidos, true)) {
            return $this->resultadoArchivo(false, 'El currículum debe ser PDF, DOC o DOCX.');
        }

        return [
            'exito' => true,
            'mensaje' => '',
            'mime' => $mime,
        ];
    }

    private function guardarCurriculum(array $archivo, string $mime): array
    {
        if (!function_exists('wp_handle_upload')) {
            require_once ABSPATH . 'wp-admin/includes/file.php';
        }

        $extension = $this->extensionPorMime($mime);
        $archivo['name'] = 'aut3_' . gmdate('Ymd_His') . '_' . bin2hex(random_bytes(8)) . '.' . $extension;
        $nombreOriginal = sanitize_file_name($_FILES['curriculum']['name'] ?? 'curriculum.' . $extension);
        $filtro = [$this, 'directorioCurriculum'];

        add_filter('upload_dir', $filtro);
        $subida = wp_handle_upload($archivo, [
            'test_form' => false,
            'mimes' => [
                'pdf' => 'application/pdf',
                'doc' => 'application/msword',
                'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            ],
        ]);
        remove_filter('upload_dir', $filtro);

        if (isset($subida['error'])) {
            return $this->falloArchivo('No fue posible guardar el currículum.');
        }

        $uploads = wp_get_upload_dir();
        $rutaRelativa = ltrim(str_replace(wp_normalize_path($uploads['basedir']), '', wp_normalize_path($subida['file'])), '/');

        return [
            'exito' => true,
            'mensaje' => '',
            'datos' => [
                'archivo' => $subida['file'],
                'ruta' => $rutaRelativa,
                'nombre' => $nombreOriginal,
                'mime' => $mime,
                'tamanio' => (int) $archivo['size'],
            ],
        ];
    }

    public function directorioCurriculum(array $directorio): array
    {
        $subdir = '/aut3-curriculums';
        $directorio['path'] = $directorio['basedir'] . $subdir;
        $directorio['url'] = $directorio['baseurl'] . $subdir;
        $directorio['subdir'] = $subdir;

        return $directorio;
    }

    private function eliminarCurriculum(string $archivo): void
    {
        if ($archivo !== '' && is_file($archivo)) {
            wp_delete_file($archivo);
        }
    }

    private function texto(mixed $valor): string
    {
        return trim(sanitize_text_field(wp_unslash((string) $valor)));
    }

    private function listaSeparadaPorComas(mixed $valor): array
    {
        $items = explode(',', sanitize_textarea_field(wp_unslash((string) $valor)));

        return array_values(array_filter(array_map(static fn (string $item): string => trim($item), $items)));
    }

    private function tieneDuplicados(array $valores, callable $clave): bool
    {
        $vistos = [];

        foreach ($valores as $valor) {
            $llave = $clave($valor);

            if (isset($vistos[$llave])) {
                return true;
            }

            $vistos[$llave] = true;
        }

        return false;
    }

    private function mimeReal(string $archivo): string
    {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);

        if (!$finfo) {
            return '';
        }

        $mime = finfo_file($finfo, $archivo) ?: '';
        finfo_close($finfo);

        return $mime;
    }

    private function extensionPorMime(string $mime): string
    {
        return match ($mime) {
            'application/msword' => 'doc',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
            default => 'pdf',
        };
    }

    private function resultadoArchivo(bool $exito, string $mensaje): array
    {
        return [
            'exito' => $exito,
            'mensaje' => $mensaje,
            'mime' => '',
        ];
    }

    private function falloArchivo(string $mensaje): array
    {
        return [
            'exito' => false,
            'mensaje' => $mensaje,
            'datos' => null,
        ];
    }

    private function fallo(string $mensaje, array $errores = []): array
    {
        return [
            'exito' => false,
            'mensaje' => $mensaje,
            'errores' => $errores,
            'datos' => null,
        ];
    }
}
