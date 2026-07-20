<?php 

declare(strict_types=1);

use App\Controllers\HomeController;
use App\Controllers\OferentesController;
use App\Controllers\ContratacionController;
use App\Core\Sesion;

require __DIR__.'/app/bootstrap.php';

Sesion::start();

$controller = new HomeController();
$oferentesController = new OferentesController();
$contratacionController = new ContratacionController();

$action = filter_input(INPUT_GET, 'action') ?: 'index';

try {
    match ($action) {
        'index' => $controller->index(),
        'detalle-oferente', 'detalleOferente' =>
            $contratacionController->detalleOferente(),
        'crear-empleado' =>
            $contratacionController->crearEmpleado(),
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
