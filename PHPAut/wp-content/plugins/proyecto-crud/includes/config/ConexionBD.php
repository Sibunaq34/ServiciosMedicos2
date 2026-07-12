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

            $host = "localhost";
            $puerto = "3307"; 
            $baseDatos = "servicios";
            $usuario = "root";
            $password = "";

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