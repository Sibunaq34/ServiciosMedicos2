<?php
declare(strict_types=1);
namespace App\Controllers;

use App\Core\Sesion;
use App\Repositories\PuestoRepository;
use RuntimeException;
use Throwable;

final class PuestosController
{
    public function index(): void
    {
        Sesion::requerirAutenticacion();
        $puestos = [];
        $error = null;
        try {
            $puestos = (new PuestoRepository())->listarActivos();
            usort($puestos, static fn (array $a, array $b): int => strcasecmp($a['nombrePuesto'], $b['nombrePuesto']));
        } catch (RuntimeException $exception) {
            $error = $exception->getMessage() === 'CORE1_NO_DISPONIBLE'
                ? 'El servicio de puestos todavía no se encuentra disponible.'
                : 'No fue posible consultar los puestos disponibles.';
        } catch (Throwable) {
            $error = 'No fue posible consultar los puestos disponibles.';
        }
        render('puestos', ['title' => 'Puestos activos', 'puestos' => $puestos, 'error' => $error]);
    }
}
