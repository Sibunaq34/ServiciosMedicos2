<?php

class ConexionBD
{
    private static ?PDO $conexion = null;

    private function __construct()
    {
    }

    public static function obtenerConexion(): PDO
    {
        if (self::$conexion === null) {

            $host = 'elegant-perlman.138-59-135-33.plesk.page';
            $puerto = "3306"; 
            $baseDatos = "Servicios";
            $usuario = "Sibuna2";
            $password = "Sibu1234.";

            $dsn = "mysql:host=$host;port=$puerto;dbname=$baseDatos;charset=utf8mb4";

            try {

                self::$conexion = new PDO(
                    $dsn,
                    $usuario,
                    $password,
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::ATTR_EMULATE_PREPARES => false
                    ]
                );

            } catch (PDOException $e) {

                die("Error de conexión: " . $e->getMessage());

            }
        }

        return self::$conexion;
    }
}