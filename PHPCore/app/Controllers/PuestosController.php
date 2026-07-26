<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;
use App\Core\Validador;
use App\Repositories\PuestoRepository;
use Throwable;

final class PuestosController
{
    private const TAMANO_PAGINA = 10;

    private PuestoRepository $repositorio;

    public function __construct()
    {
        $this->repositorio = new PuestoRepository();
    }

    public function index(): void
    {
        Sesion::requerirAutenticacion();
        $pagina = Validador::pagina(filter_input(INPUT_GET, 'pagina'));

        try {
            $todos = $this->repositorio->listarActivos();
            usort($todos, static fn (array $a, array $b): int =>
                strcasecmp($a['nombrePuesto'], $b['nombrePuesto'])
            );
            $totalRegistros = count($todos);
            $totalPaginas = max(1, (int) ceil($totalRegistros / self::TAMANO_PAGINA));
            $pagina = min($pagina, $totalPaginas);
            $puestos = array_slice(
                $todos,
                ($pagina - 1) * self::TAMANO_PAGINA,
                self::TAMANO_PAGINA
            );
            $error = null;
        } catch (Throwable $exception) {
            error_log($exception->__toString());
            $puestos = [];
            $totalPaginas = 1;
            $totalRegistros = 0;
            $pagina = 1;
            $error = 'No fue posible obtener los puestos activos. Verifique que el servicio se encuentre disponible e intente nuevamente.';
        }

        render('puestos', [
            'title' => 'Puestos activos',
            'puestos' => $puestos,
            'error' => $error,
            'paginaActual' => $pagina,
            'totalPaginas' => $totalPaginas,
            'totalRegistros' => $totalRegistros,
        ]);
    }
}
