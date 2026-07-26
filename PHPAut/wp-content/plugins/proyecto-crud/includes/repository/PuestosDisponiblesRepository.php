<?php

require_once plugin_dir_path(__DIR__) . 'config/ConexionBD.php';

class PuestosDisponiblesRepository
{
    private PDO $conexion;

    public function __construct()
    {
        $this->conexion = ConexionBD::obtenerConexion();
    }

    public function obtenerActivos(): array
    {
        try {
            $stmt = $this->conexion->prepare(
                'SELECT codigo_puesto, nombre_puesto
                 FROM puestos
                 WHERE activo = :activo
                 ORDER BY nombre_puesto ASC'
            );

            $stmt->execute([':activo' => 1]);

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log('PuestosDisponiblesRepository::obtenerActivos: ' . $e->getMessage());

            return [];
        }
    }
}
