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

// Persona C - Kenneth
// Inicio de la integracion visual de AUT3.
const AUT3_REGISTRO_OFERENTE_VERSION = '0.1.0';

add_shortcode('registro_oferente_aut3', 'aut3_registro_oferente_shortcode');

function aut3_registro_oferente_shortcode()
{
    aut3_registro_oferente_enqueue_assets();

    $aut3_datos_puesto = aut3_registro_oferente_obtener_puesto_temporal();
    $aut3_url_retorno = aut3_registro_oferente_obtener_url_retorno();

    ob_start();

    include plugin_dir_path(__FILE__) . 'templates/registro-oferente.php';

    return ob_get_clean();
}

function aut3_registro_oferente_enqueue_assets()
{
    wp_enqueue_style(
        'aut3-registro-oferente',
        plugins_url('assets/css/aut3-registro-oferente.css', __FILE__),
        [],
        AUT3_REGISTRO_OFERENTE_VERSION
    );

    wp_enqueue_script(
        'aut3-registro-oferente',
        plugins_url('assets/js/aut3-registro-oferente.js', __FILE__),
        [],
        AUT3_REGISTRO_OFERENTE_VERSION,
        true
    );
}

function aut3_registro_oferente_obtener_puesto_temporal()
{
    // Persona C - Kenneth
    // Integracion temporal con AUT2.
    // Reemplazar cuando AUT2 defina el contrato definitivo.
    $codigoPuesto = isset($_GET['codigo_puesto'])
        ? sanitize_text_field(wp_unslash($_GET['codigo_puesto']))
        : '';

    $nombrePuesto = isset($_GET['nombre_puesto'])
        ? sanitize_text_field(wp_unslash($_GET['nombre_puesto']))
        : '';

    if ($codigoPuesto === '' && $nombrePuesto === '') {
        return [
            'codigo' => '',
            'nombre' => 'Puesto pendiente de integracion con AUT2',
        ];
    }

    return [
        'codigo' => $codigoPuesto,
        'nombre' => $nombrePuesto !== '' ? $nombrePuesto : $codigoPuesto,
    ];
}

function aut3_registro_oferente_obtener_url_retorno()
{
    $fallback = home_url('/');

    $urlRetorno = isset($_GET['url_retorno'])
        ? esc_url_raw(wp_unslash($_GET['url_retorno']))
        : '';

    if ($urlRetorno === '') {
        return esc_url($fallback);
    }

    return esc_url(wp_validate_redirect($urlRetorno, $fallback));
}
// Persona C - Kenneth
// Fin de la integracion visual de AUT3.
