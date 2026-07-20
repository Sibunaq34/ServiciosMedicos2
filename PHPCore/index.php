<?php 

declare(strict_types=1);

use App\Controllers\HomeController;
use App\Controllers\DetalleOferenteController;
use App\Controllers\OferentesController;
use App\Core\Sesion;

require __DIR__.'/app/bootstrap.php';

Sesion::start();

$controller = new HomeController();
$detalleOferenteController = new DetalleOferenteController();
$oferentesController = new OferentesController();

$action = filter_input(INPUT_GET, 'action') ?: 'index';

try {
    match ($action) {
        'index' => $controller->index(),
        'core9' => $controller->detalleOferente(),
        'detalle-oferente' => $controller->detalleOferente(),
        'core3' => $controller->crearEmpleado(),
        'crear-empleado' => $controller->crearEmpleado(),
        // Persona C - Kenneth
        // Ruta para consultar el detalle completo del oferente en CORE8.
        'detalle-oferente-core8' => $detalleOferenteController->detalle(),
        'oferentes' => $oferentesController->oferentesPorPuesto(),
        'listado-oferentes' => $oferentesController->listadoOferentes(),
        default => $controller->notFound(),
    };

} catch (Throwable $exception) {
    http_response_code(500);

    error_log($exception->__toString());

    render('errors/500', [
        'title' => 'Error al cargar la página',
        'message' => 'No fue posible completar la operación',
    ]);
}
