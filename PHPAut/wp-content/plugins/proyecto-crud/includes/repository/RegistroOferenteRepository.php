<?php

require_once plugin_dir_path(__DIR__) . 'config/ConexionBD.php';

class RegistroOferenteRepository
{
    private PDO $conexion;

    public function __construct()
    {
        $this->conexion = ConexionBD::obtenerConexion();
    }

    public function obtenerPuestoActivoPorCodigo(string $codigoPuesto): ?array
    {
        $stmt = $this->conexion->prepare(
            'SELECT id_puesto, codigo_puesto, nombre_puesto
             FROM puestos
             WHERE codigo_puesto = :codigo_puesto
               AND activo = :activo
             ORDER BY id_puesto ASC
             LIMIT 1'
        );

        $stmt->execute([
            ':codigo_puesto' => $codigoPuesto,
            ':activo' => 1,
        ]);

        $puesto = $stmt->fetch(PDO::FETCH_ASSOC);

        return $puesto ?: null;
    }

    public function existeIdentificacion(string $identificacion): bool
    {
        $stmt = $this->conexion->prepare(
            'SELECT 1 FROM personas WHERE identificacion = :identificacion LIMIT 1'
        );

        $stmt->execute([':identificacion' => $identificacion]);

        return (bool) $stmt->fetchColumn();
    }

    public function registrar(array $datos): array
    {
        try {
            $idUsuarioTecnico = $this->obtenerIdUsuarioTecnico();

            if ($idUsuarioTecnico === null) {
                return $this->fallo('No se encontro el usuario tecnico de AUT3.');
            }

            $stmt = $this->conexion->prepare(
                'CALL sp_aut3_registrar_oferente_puesto(
                    :tipo_identificacion,
                    :identificacion,
                    :nombre_completo,
                    :fecha_nacimiento,
                    :correos_json,
                    :telefonos_json,
                    :codigo_puesto,
                    :ruta_curriculum,
                    :nombre_curriculum,
                    :mime_curriculum,
                    :tamanio_curriculum,
                    :id_usuario_tecnico
                )'
            );

            $stmt->execute([
                ':tipo_identificacion' => $datos['tipo_identificacion'],
                ':identificacion' => $datos['identificacion'],
                ':nombre_completo' => $datos['nombre_completo'],
                ':fecha_nacimiento' => $datos['fecha_nacimiento'],
                ':correos_json' => wp_json_encode($datos['correos']),
                ':telefonos_json' => wp_json_encode($datos['telefonos']),
                ':codigo_puesto' => $datos['codigo_puesto'],
                ':ruta_curriculum' => $datos['curriculum']['ruta'],
                ':nombre_curriculum' => $datos['curriculum']['nombre'],
                ':mime_curriculum' => $datos['curriculum']['mime'],
                ':tamanio_curriculum' => $datos['curriculum']['tamanio'],
                ':id_usuario_tecnico' => $idUsuarioTecnico,
            ]);

            $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            if (!$resultado) {
                return $this->fallo('No se recibio confirmacion del registro.');
            }

            return [
                'exito' => true,
                'mensaje' => 'Datos guardados de manera satisfactoria',
                'datos' => $resultado,
            ];
        } catch (PDOException $e) {
            return $this->fallo($this->mensajeControlado($e));
        }
    }

    private function obtenerIdUsuarioTecnico(): ?int
    {
        $stmt = $this->conexion->prepare(
            'SELECT id_usuario
             FROM usuarios
             WHERE usuario = :usuario
               AND activo = :activo
             ORDER BY id_usuario ASC
             LIMIT 1'
        );

        $stmt->execute([
            ':usuario' => 'AUT_PUBLICO',
            ':activo' => 0,
        ]);

        $idUsuario = $stmt->fetchColumn();

        return $idUsuario ? (int) $idUsuario : null;
    }

    private function mensajeControlado(PDOException $e): string
    {
        $mensaje = $e->errorInfo[2] ?? $e->getMessage();

        if (str_contains($mensaje, 'El numero de identificacion ya existe')) {
            return 'La identificacion indicada ya se encuentra registrada.';
        }

        if (str_contains($mensaje, 'puesto indicado')) {
            return 'El puesto seleccionado no existe o ya no esta disponible.';
        }

        if (str_contains($mensaje, 'Duplicate')) {
            return 'Ya existe un registro con los mismos datos.';
        }

        if (str_contains($mensaje, 'correo')) {
            return 'Revise los correos indicados.';
        }

        if (str_contains($mensaje, 'telefono')) {
            return 'Revise los telefonos indicados.';
        }

        return 'No fue posible completar el registro. Intente nuevamente.';
    }

    private function fallo(string $mensaje): array
    {
        return [
            'exito' => false,
            'mensaje' => $mensaje,
            'datos' => null,
        ];
    }
}
