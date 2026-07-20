<?php 

declare(strict_types=1);

use App\Controllers\HomeController;
use App\Controllers\DetalleOferenteController;
use App\Controllers\OferentesController;
use App\Controllers\ContratacionController;
use App\Controllers\LoginController;
use App\Controllers\PuestosController;
use App\Controllers\ExpedientesController;
use App\Core\Sesion;

require __DIR__.'/app/bootstrap.php';

Sesion::start();

$action = filter_input(INPUT_GET, 'action') ?: 'login';

try {
    if (!in_array($action, ['login', 'procesar-login'], true)) {
        Sesion::requerirAutenticacion();
    }

    match ($action) {
        'index' => (new HomeController())->index(),
        'login' => (new LoginController())->mostrarLogin(),
        'procesar-login' => (new LoginController())->procesarLogin(),
        'logout' => (new LoginController())->logout(),
        'puestos' => (new PuestosController())->index(),
        'expedientes' => (new ExpedientesController())->index(),
        'expediente-crear' => (new ExpedientesController())->crear(),
        'expediente-consultar' => (new ExpedientesController())->consultar(),
        'expediente-editar' => (new ExpedientesController())->editar(),
        // Persona C - Kenneth
        // Ruta para consultar el detalle completo del oferente en CORE8.
        'detalle-oferente-core8' => (new DetalleOferenteController())->detalle(),
        'detalle-oferente', 'detalleOferente' => (new ContratacionController())->detalleOferente(),
        'crear-empleado' => (new ContratacionController())->crearEmpleado(),
        'oferentes' => (new OferentesController())->oferentesPorPuesto(),
        'listado-oferentes' => (new OferentesController())->listadoOferentes(),
        default => (new HomeController())->notFound(),
    };

} catch (Throwable $exception) {
    http_response_code(500);

    error_log($exception->__toString());

    render('errors/500', [
        'title' => 'Error al cargar la página',
        'message' => 'No fue posible completar la operación',
    ]);
}
