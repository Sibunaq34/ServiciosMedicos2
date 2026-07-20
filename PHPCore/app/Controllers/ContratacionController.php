<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;
use App\Core\Validador;
use App\Repositories\DetalleOferenteRepository;
use App\Repositories\EmpleadoRepository;
use Throwable;

final class ContratacionController
{
    public function __construct(
        private ?DetalleOferenteRepository $oferentes = null,
        private ?EmpleadoRepository $empleados = null
    ) {
        $this->oferentes ??= new DetalleOferenteRepository();
        $this->empleados ??= new EmpleadoRepository();
    }

    public function detalleOferente(): void
    {
        if (!$this->autorizar()) {
            return;
        }

        $id = Validador::idPositivo(filter_input(INPUT_GET, 'id'));
        $codigoPuesto = Validador::codigoPuesto(filter_input(INPUT_GET, 'codigo_puesto')) ?? '';
        $error = null;
        $oferente = null;
        $yaEsEmpleado = false;

        if ($id === null) {
            $error = 'No se proporcionó un oferente válido.';
        } else {
            try {
                $resultado = $this->oferentes->obtenerDetalle($id);
                $oferente = $resultado['datos'];
                $error = $resultado['exito'] ? null : $resultado['mensaje'];
                if ($error === null && $oferente !== null) {
                    $yaEsEmpleado = $this->empleados->oferenteEsEmpleado($id);
                }
            } catch (Throwable $exception) {
                error_log($exception->__toString());
                $error = 'No fue posible consultar el detalle del oferente.';
            }
        }

        render('contratacion/detalle-oferente', [
            'title' => 'Detalle de oferente',
            'oferente' => $oferente,
            'error' => $error,
            'codigoPuesto' => $codigoPuesto,
            'mensajeExito' => Sesion::getFlash('contratacion_exito'),
            'mensajeError' => Sesion::getFlash('contratacion_error'),
            'csrfToken' => Sesion::csrfToken(),
            'yaEsEmpleado' => $yaEsEmpleado,
        ]);
    }

    public function crearEmpleado(): void
    {
        if (!$this->autorizar()) {
            return;
        }

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
            http_response_code(405);
            Sesion::flash('contratacion_error', 'La creación debe enviarse mediante POST.');
            redirect(url('detalle-oferente', array_filter([
                'id' => filter_input(INPUT_GET, 'id'),
                'codigo_puesto' => Validador::codigoPuesto(filter_input(INPUT_GET, 'codigo_puesto')),
            ])));
        }

        $idOferente = Validador::idPositivo($_POST['id_oferente'] ?? null);
        $idJefatura = Validador::idPositivo($_POST['id_jefatura'] ?? null);
        $codigoPuesto = Validador::codigoPuesto($_POST['codigo_puesto'] ?? null);
        $regreso = url('detalle-oferente', array_filter([
            'id' => $idOferente,
            'codigo_puesto' => $codigoPuesto,
        ]));

        if (!Sesion::verifyCsrf($_POST['_csrf'] ?? null)) {
            http_response_code(419);
            Sesion::flash('contratacion_error', 'La sesión del formulario expiró.');
            redirect($regreso);
        }

        if ($idOferente === null || $codigoPuesto === null) {
            Sesion::flash('contratacion_error', 'Los datos para crear el empleado son inválidos.');
            redirect($regreso);
        }

        try {
            if ($this->empleados->oferenteEsEmpleado($idOferente)) {
                Sesion::flash('contratacion_error', 'El oferente ya fue registrado como empleado.');
                redirect($regreso);
            }

            $resultado = $this->empleados->registrar([
                'IdOferente' => $idOferente,
                'CodigoPuesto' => $codigoPuesto,
                'IdJefatura' => $idJefatura,
                'IdUsuario' => Sesion::usuarioId(),
            ]);

            Sesion::flash(
                $resultado['exito'] ? 'contratacion_exito' : 'contratacion_error',
                $resultado['mensaje']
            );
        } catch (Throwable $exception) {
            error_log($exception->__toString());
            Sesion::flash('contratacion_error', 'El servicio de empleados no está disponible.');
        }

        redirect($regreso);
    }

    private function autorizar(): bool
    {
        if (Sesion::estaAutenticado()) {
            return true;
        }

        http_response_code(403);
        render('errors/403', [
            'title' => 'Acceso denegado',
            'message' => 'Debe iniciar sesión para consultar oferentes.',
        ]);
        return false;
    }
}
