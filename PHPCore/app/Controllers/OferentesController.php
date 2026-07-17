<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Validador;
use App\Repositories\OferenteRepository;

final class OferentesController
{
    private const TAMANO_PAGINA = 10;

    private OferenteRepository $repositorio;

    public function __construct()
    {
        $this->repositorio = new OferenteRepository();
    }

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

    public function listadoOferentes(): void
    {


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
