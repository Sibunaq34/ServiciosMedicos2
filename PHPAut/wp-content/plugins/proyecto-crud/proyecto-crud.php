<?php
/*
Plugin Name: Proyecto CRUD
Description: Plugin para conectar WordPress con la base de datos del proyecto mediante procedimientos almacenados.
Version: 1.0.0
Author: Tu equipo
*/

if (!defined('ABSPATH')) {
    exit; // Evita el acceso directo al archivo
}

require_once plugin_dir_path(__FILE__) . 'includes/config/ConexionBD.php';
require_once plugin_dir_path(__FILE__) . 'includes/repository/BitacoraRepository.php';

add_shortcode('bitacoras', 'mostrarBitacoras');

function mostrarBitacoras()
{
    $repo = new BitacoraRepository();
    $bitacoras = $repo->consultar();

    ob_start();

    include plugin_dir_path(__FILE__) . 'templates/bitacoras.php';

    return ob_get_clean();
}