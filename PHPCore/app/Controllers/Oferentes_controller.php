<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Validador;
use App\Repositories\OferenteRepository;

/**
 * Controlador de Oferentes.
 * Implementa únicamente los métodos GET de:
 *   - HU CORE2 (web service): oferentesPorPuesto()
 *   - HU CORE7 (pantalla): listadoOferentes()
 *
 * Los métodos POST NO se implementan en esta entrega, ya que corresponden
 * al web service formal que se construirá más adelante.
 *
 * Convención de nombre: Entidad_controller (ej. Oferentes_controller,
 * RequisitosPuestos_controller), para que index.php despache por ese
 * mismo nombre en vez de un estándar genérico tipo XController.
 */
final class Oferentes_controller
{
    private const TAMANO_PAGINA = 10;

    private OferenteRepository $repositorio;

    public function __construct()
    {
        $this->repositorio = new OferenteRepository();
    }

    /**
     * HU CORE2 - GET
     * "Servicio que a partir de un código de puesto regresa los oferentes
     * que cumplen los requisitos de este."
     *
     * Por defecto responde JSON (contrato original del web service, para
     * consumidores programáticos). Si la petición viene de un navegador
     * (header Accept incluye text/html), responde una tabla HTML con el
     * mismo estilo que la vista de CORE7, solo para facilitar la revisión
     * visual del resultado durante el desarrollo/QA.
     *
     * Ejemplo de uso: index.php?action=oferentesPorPuesto&codigo_puesto=GER005
     */
    public function oferentesPorPuesto(): void
    {
        $codigoPuesto = Validador::codigoPuesto(filter_input(INPUT_GET, 'codigo_puesto'));
        $aceptaHtml = str_contains($_SERVER['HTTP_ACCEPT'] ?? '', 'text/html');

        if ($codigoPuesto === null) {
            if ($aceptaHtml) {
                render('oferentes/servicio', [
                    'title'        => 'Oferentes por Puesto (CORE2)',
                    'error'        => 'El parámetro codigo_puesto es requerido y debe ser válido.',
                    'oferentes'    => [],
                    'codigoPuesto' => null,
                ]);
                return;
            }

            header('Content-Type: application/json; charset=utf-8');
            http_response_code(400);
            echo json_encode([
                'error' => 'El parámetro codigo_puesto es requerido y debe ser válido.',
            ]);
            return;
        }

        $oferentes = $this->repositorio->obtenerPorPuesto($codigoPuesto);

        if ($aceptaHtml) {
            render('oferentes/servicio', [
                'title'        => 'Oferentes por Puesto (CORE2)',
                'error'        => null,
                'oferentes'    => $oferentes,
                'codigoPuesto' => $codigoPuesto,
            ]);
            return;
        }

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'codigo_puesto' => $codigoPuesto,
            'total'         => count($oferentes),
            'oferentes'     => $oferentes,
        ]);
    }

    /**
     * HU CORE7 - GET
     * Pantalla de listado de oferentes para seleccionar el nuevo empleado.
     * Consume la misma capa de servicio que expone CORE2 (mismo repositorio).
     *
     * Ejemplo de uso: index.php?action=listadoOferentes&codigo_puesto=GER005&pagina=1
     */
    public function listadoOferentes(): void
    {
        // TODO: verificar sesión/autenticación aquí una vez que exista un
        // método real en App\Core\Sesion para ello (en el análisis de
        // arquitectura no se encontró ningún controlador que valide sesión
        // todavía, así que no se asume una firma de método que no existe).

        $codigoPuesto = Validador::codigoPuesto(filter_input(INPUT_GET, 'codigo_puesto'));
        $pagina = Validador::pagina(filter_input(INPUT_GET, 'pagina'));

        if ($codigoPuesto === null) {
            render('oferentes/listado', [
                'title'        => 'Listado de Oferentes',
                'error'        => 'Debe indicar un código de puesto válido.',
                'oferentes'    => [],
                'codigoPuesto' => null,
                'paginaActual' => 1,
                'totalPaginas' => 1,
            ]);
            return;
        }

        $todos = $this->repositorio->obtenerPorPuesto($codigoPuesto);

        $totalRegistros = count($todos);
        $totalPaginas = max(1, (int) ceil($totalRegistros / self::TAMANO_PAGINA));
        $pagina = min($pagina, $totalPaginas);
        $offset = ($pagina - 1) * self::TAMANO_PAGINA;
        $oferentesPagina = array_slice($todos, $offset, self::TAMANO_PAGINA);

        // Bitácora: "El usuario consulta listado de oferentes para puesto <código>"
        // TODO: reemplazar por la función/clase real de bitácora del proyecto
        // cuando exista (no se encontró ninguna implementación de registro,
        // solo de consulta, en el análisis de arquitectura).
        // Ejemplo esperado: Bitacora::registrar('Consulta',
        //     "El usuario consulta listado de oferentes para puesto {$codigoPuesto}");

        render('oferentes/listado', [
            'title'        => 'Listado de Oferentes',
            'error'        => null,
            'oferentes'    => $oferentesPagina,
            'codigoPuesto' => $codigoPuesto,
            'paginaActual' => $pagina,
            'totalPaginas' => $totalPaginas,
        ]);
    }
}
