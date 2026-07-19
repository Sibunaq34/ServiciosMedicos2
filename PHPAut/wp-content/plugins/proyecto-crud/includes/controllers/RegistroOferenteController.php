<?php

require_once plugin_dir_path(__DIR__) . 'services/RegistroOferenteService.php';

class RegistroOferenteController
{
    private RegistroOferenteService $service;

    public function __construct(?RegistroOferenteService $service = null)
    {
        $this->service = $service ?: new RegistroOferenteService();
    }

    public function registrar(): void
    {
        // Persona C - Kenneth
        // Coordina el registro publico del oferente.
        if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
            wp_send_json_error([
                'mensaje' => 'Metodo no permitido.',
                'errores' => [],
            ], 405);
        }

        if (!check_ajax_referer('aut3_registro_oferente', 'nonce', false)) {
            wp_send_json_error([
                'mensaje' => 'La solicitud no es valida. Recargue la pagina e intente de nuevo.',
                'errores' => [],
            ], 403);
        }

        $resultado = $this->service->registrar($_POST, $_FILES['curriculum'] ?? null);

        if (!$resultado['exito']) {
            wp_send_json_error([
                'mensaje' => $resultado['mensaje'],
                'errores' => $resultado['errores'] ?? [],
            ], 400);
        }

        wp_send_json_success([
            'mensaje' => $resultado['mensaje'],
            'datos' => $resultado['datos'],
        ]);
    }
}
