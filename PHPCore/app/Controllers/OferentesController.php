<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;
use App\Core\Validador;
use App\Repositories\OferenteRepository;
use RuntimeException;
use SoapFault;
use Throwable;

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
        Sesion::requerirAutenticacion();
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

        try {
            $oferentes = $this->repositorio->listarPorPuesto($codigoPuesto);
        } catch (SoapFault | RuntimeException $exception) {
            $this->responderErrorServicio($aceptaHtml, $codigoPuesto, $exception);
            return;
        } catch (Throwable $exception) {
            $this->responderErrorServicio($aceptaHtml, $codigoPuesto, $exception);
            return;
        }

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
        Sesion::requerirAutenticacion();
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

        try {
            $todos = $this->repositorio->listarPorPuesto($codigoPuesto);
        } catch (SoapFault | RuntimeException $exception) {
            error_log($exception->__toString());
            $this->renderizarListadoConError($codigoPuesto);
            return;
        } catch (Throwable $exception) {
            error_log($exception->__toString());
            $this->renderizarListadoConError($codigoPuesto);
            return;
        }

        $totalRegistros = count($todos);
        $totalPaginas = max(1, (int) ceil($totalRegistros / self::TAMANO_PAGINA));
        $pagina = min($pagina, $totalPaginas);

        $oferentesPagina = array_slice($todos, ($pagina - 1) * self::TAMANO_PAGINA, self::TAMANO_PAGINA);

        render('oferentes/listado', [
            'title'        => 'Listado de Oferentes',
            'error'        => null,
            'oferentes'    => $oferentesPagina,
            'codigoPuesto' => $codigoPuesto,
            'paginaActual' => $pagina,
            'totalPaginas' => $totalPaginas,
        ]);
    }

    private function responderErrorServicio(bool $aceptaHtml, string $codigoPuesto, Throwable $exception): void
    {
        error_log($exception->__toString());
        $mensaje = 'No fue posible consultar los oferentes para el puesto seleccionado.';

        if ($aceptaHtml) {
            render('oferentes/servicio', [
                'title' => 'Oferentes por Puesto (CORE2)',
                'error' => $mensaje,
                'oferentes' => [],
                'codigoPuesto' => $codigoPuesto,
            ]);
            return;
        }

        header('Content-Type: application/json; charset=utf-8');
        http_response_code(503);
        echo json_encode(['error' => $mensaje], JSON_UNESCAPED_UNICODE);
    }

    private function renderizarListadoConError(string $codigoPuesto): void
    {
        render('oferentes/listado', [
            'title' => 'Listado de Oferentes',
            'error' => 'No fue posible consultar los oferentes para el puesto seleccionado.',
            'oferentes' => [],
            'codigoPuesto' => $codigoPuesto,
            'paginaActual' => 1,
            'totalPaginas' => 1,
        ]);
    }
}
