<?php 

declare(strict_types=1);

use App\Controllers\HomeController;
use App\Controllers\Oferentes_controller;
use App\Controllers\Oferentes_controller;
use App\Core\Sesion;

require __DIR__.'/app/bootstrap.php';

Sesion::start();

$action = filter_input(INPUT_GET, 'action') ?: 'index';

try {
    match ($action) {
        'index' => $controller->index(),
        // Rutas GET visuales de las historias asignadas.
        'core9' => $controller->detalleOferente(),
        'detalle-oferente' => $controller->detalleOferente(),
        'core3' => $controller->crearEmpleado(),
        'crear-empleado' => $controller->crearEmpleado(),
        default => $controller->notFound(),
        'index'              => (new HomeController())->index(),
        'oferentesPorPuesto' => (new Oferentes_controller())->oferentesPorPuesto(),
        'listadoOferentes'   => (new Oferentes_controller())->listadoOferentes(),
        default              => (new HomeController())->notFound(),
    };
} catch (Throwable $exception) {
    http_response_code(500);

    error_log($exception->__toString());

    render('errors/500', [
        'title' => 'Error al cargar la página',
        'message' => 'No fue posible completar la operación',
    ]);
}
