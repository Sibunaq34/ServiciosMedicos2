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
            'nombre' => 'Seleccione un puesto disponible desde AUT2',
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

function aut2_obtener_puestos_disponibles()
{
    try {
        $conexion = ConexionBD::obtenerConexion();

        $stmt = $conexion->prepare(
            'SELECT codigo_puesto, nombre_puesto FROM puestos WHERE activo = :activo ORDER BY nombre_puesto ASC'
        );

        $stmt->execute([':activo' => 1]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log('aut2_obtener_puestos_disponibles: ' . $e->getMessage());

        return [];
    }
}

function aut2_obtener_url_registro_oferente()
{
    // La URL de Aut3 se resuelve en tiempo de ejecucion 
    // Se busca por slug en vez de fijar el post ID para no depender de que
    $pagina = get_page_by_path('registro-de-oferente', OBJECT, 'page');

    if ($pagina instanceof WP_Post) {
        $permalink = get_permalink($pagina);

        if ($permalink) {
            return $permalink;
        }
    }

    return home_url('/');
}

function aut2_construir_url_aut3($urlAut3, $codigoPuesto, $nombrePuesto, $urlRetorno)
{
    
    $query = [
        'codigo_puesto' => rawurlencode($codigoPuesto),
        'nombre_puesto' => rawurlencode($nombrePuesto),
        'url_retorno'   => rawurlencode($urlRetorno),
    ];

    return esc_url(add_query_arg($query, $urlAut3));
}

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

    $aut2Puestos = aut2_obtener_puestos_disponibles();
    $aut2UrlAut3 = aut2_obtener_url_registro_oferente();
    $aut2UrlActual = home_url(add_query_arg(null, null));

    ob_start();
    ?>
    <section class="aut2-puestos-disponibles">
        <?php if (empty($aut2Puestos)): ?>
            <p class="aut2-vacio">No hay puestos disponibles en este momento.</p>
        <?php else: ?>
            <div class="aut2-grid">
                <?php foreach ($aut2Puestos as $aut2Puesto): ?>
                    <?php
                    $aut2Codigo = (string) $aut2Puesto['codigo_puesto'];
                    $aut2Nombre = (string) $aut2Puesto['nombre_puesto'];
                    $aut2Href = aut2_construir_url_aut3($aut2UrlAut3, $aut2Codigo, $aut2Nombre, $aut2UrlActual);
                    ?>
                    <a class="aut2-card" href="<?php echo esc_url($aut2Href); ?>">
                        <span class="aut2-card-nombre"><?php echo esc_html($aut2Nombre); ?></span>
                        <span class="aut2-card-codigo"><?php echo esc_html($aut2Codigo); ?></span>
                    </a>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </section>
    <?php
    return ob_get_clean();
}
