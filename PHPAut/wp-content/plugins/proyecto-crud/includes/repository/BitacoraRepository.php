<?php

require_once plugin_dir_path(__DIR__) . 'config/ConexionBD.php';

class BitacoraRepository
{
    private PDO $conexion;

    public function __construct()
    {
        $this->conexion = ConexionBD::obtenerConexion();
    }

    public function consultar()
    {
        $stmt = $this->conexion->prepare(
            "CALL ConsultarBitacoras(:usuario,:descripcion,:pagina,:tamano)"
        );

        $stmt->execute([
            ':usuario' => '',
            ':descripcion' => '',
            ':pagina' => 1,
            ':tamano' => 20
        ]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}