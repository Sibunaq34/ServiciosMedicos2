<?php 

declare(strict_types=1);

use App\Controllers\HomeController;
use App\Controllers\DetalleOferenteController;
use App\Controllers\OferentesController;
use App\Controllers\ContratacionController;
use App\Controllers\LoginController;
use App\Controllers\PuestosController;
use App\Controllers\ExpedientesController;
use App\Controllers\UsuariosController;
use App\Core\Sesion;

require __DIR__.'/app/bootstrap.php';

Sesion::start();

$controller = new HomeController();
$detalleOferenteController = new DetalleOferenteController();
$oferentesController = new OferentesController();
$contratacionController = new ContratacionController();
$loginController = new LoginController();
$puestosController = new PuestosController();
$expedientesController = new ExpedientesController();
$usuariosController = new UsuariosController();

$action = filter_input(INPUT_GET, 'action') ?: 'index';

try {
    if (!in_array($action, ['login', 'procesar-login'], true)) {
        Sesion::requerirAutenticacion();
    }

    match ($action) {
        'index' => $controller->index(),
        'core9' => $contratacionController->detalleOferente(),
        'core3' => $contratacionController->crearEmpleado(),
        'login' => $loginController->mostrarLogin(),
        'procesar-login' => $loginController->procesarLogin(),
        'logout' => $loginController->logout(),
        'puestos' => $puestosController->index(),
        'puestos-crear' => $puestosController->crear(),
        'puestos-consultar' => $puestosController->consultar(),
        'puestos-editar' => $puestosController->editar(),
        'puestos-estado' => $puestosController->cambiarEstado(),
        'expedientes' => $expedientesController->index(),
        'expediente-crear' => $expedientesController->crear(),
        'expediente-consultar' => $expedientesController->consultar(),
        'expediente-editar' => $expedientesController->editar(),
        'usuarios' => $usuariosController->index(),
        'usuarios-crear' => $usuariosController->crear(),
        'usuarios-consultar' => $usuariosController->consultar(),
        'usuarios-editar' => $usuariosController->editar(),
        'usuarios-estado' => $usuariosController->cambiarEstado(),
        'core9' => $controller->detalleOferente(),
        'detalle-oferente' => $controller->detalleOferente(),
        'core3' => $controller->crearEmpleado(),
        'crear-empleado' => $controller->crearEmpleado(),
        // Persona C - Kenneth
        // Ruta para consultar el detalle completo del oferente en CORE8.
        'detalle-oferente-core8' => $detalleOferenteController->detalle(),
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
