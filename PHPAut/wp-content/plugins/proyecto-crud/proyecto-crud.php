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
require_once plugin_dir_path(__FILE__) . 'includes/repository/RegistroOferenteRepository.php';
require_once plugin_dir_path(__FILE__) . 'includes/services/RegistroOferenteService.php';
require_once plugin_dir_path(__FILE__) . 'includes/controllers/RegistroOferenteController.php';
require_once plugin_dir_path(__FILE__) . 'includes/repository/PuestosDisponiblesRepository.php';
require_once plugin_dir_path(__FILE__) . 'includes/services/PuestosDisponiblesService.php';
require_once plugin_dir_path(__FILE__) . 'includes/controllers/PuestosDisponiblesController.php';

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
// Inicio de la integracion funcional de AUT3.
const AUT3_REGISTRO_OFERENTE_VERSION = '0.1.0';

add_shortcode('registro_oferente_aut3', 'aut3_registro_oferente_shortcode');
add_action('wp_ajax_nopriv_aut3_registrar_oferente', 'aut3_registro_oferente_manejar_ajax');
add_action('wp_ajax_aut3_registrar_oferente', 'aut3_registro_oferente_manejar_ajax');

function aut3_registro_oferente_manejar_ajax()
{
    $controller = new RegistroOferenteController();
    $controller->registrar();
}

function aut3_registro_oferente_shortcode()
{
    aut3_registro_oferente_enqueue_assets();

    $aut3_datos_puesto = aut3_registro_oferente_obtener_puesto();
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

    wp_localize_script(
        'aut3-registro-oferente',
        'AUT3RegistroOferente',
        [
            'ajaxUrl' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('aut3_registro_oferente'),
        ]
    );
}

function aut3_registro_oferente_obtener_puesto()
{
    // Persona C - Kenneth
    // Revalida el puesto recibido desde AUT2.
    $codigoPuesto = isset($_GET['codigo_puesto'])
        ? sanitize_text_field(wp_unslash($_GET['codigo_puesto']))
        : '';

    $nombrePuesto = isset($_GET['nombre_puesto'])
        ? sanitize_text_field(wp_unslash($_GET['nombre_puesto']))
        : '';

    if ($codigoPuesto === '' && $nombrePuesto === '') {
        return [
            'codigo' => '',
            'nombre' => '',
        ];
    }

    if ($codigoPuesto !== '') {
        try {
            $service = new RegistroOferenteService();
            $puesto = $service->obtenerPuestoActivo($codigoPuesto);

            if ($puesto) {
                return [
                    'codigo' => (string) $puesto['codigo_puesto'],
                    'nombre' => (string) $puesto['nombre_puesto'],
                ];
            }
        } catch (Throwable $e) {
            error_log('aut3_registro_oferente_obtener_puesto: ' . $e->getMessage());
        }
    }

    return [
        'codigo' => $codigoPuesto,
        'nombre' => 'Puesto no disponible',
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
// Fin de la integracion funcional de AUT3.

// Aut2 - Listado de puestos disponibles.
const AUT2_PUESTOS_DISPONIBLES_VERSION = '0.1.0';

add_shortcode('puestos_disponibles_aut2', 'aut2_puestos_disponibles_shortcode');

function aut2_puestos_disponibles_enqueue_assets()
{
    // No hace falta JS: el listado es solo enlaces, sin interactividad.
    wp_enqueue_style(
        'aut2-puestos-disponibles',
        plugins_url('assets/css/aut2-puestos-disponibles.css', __FILE__),
        [],
        AUT2_PUESTOS_DISPONIBLES_VERSION
    );
}

function aut2_puestos_disponibles_shortcode()
{
    aut2_puestos_disponibles_enqueue_assets();

    $controller = new PuestosDisponiblesController();
    $aut2Puestos = $controller->obtenerDatosListado();

    ob_start();

    include plugin_dir_path(__FILE__) . 'templates/puestos-disponibles.php';

    return ob_get_clean();
}
