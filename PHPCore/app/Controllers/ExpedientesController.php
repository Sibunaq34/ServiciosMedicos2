<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;
use App\Repositories\ExpedientePersonalRepository;
use Throwable;

final class ExpedientesController
{
    private ExpedientePersonalRepository $repositorio;

    public function __construct()
    {
        $this->repositorio = new ExpedientePersonalRepository();
    }

    public function index(): void
    {
        Sesion::requerirAutenticacion();

        try {
            $expedientes = $this->repositorio->listar();
            $error = null;
        } catch (Throwable $exception) {
            $expedientes = [];
            $error = 'No fue posible consultar los expedientes personales.';
        }

        render('expedientes/index', [
            'title' => 'Expediente personal',
            'expedientes' => $expedientes,
            'error' => $error,
        ]);
    }

    public function crear(): void
    {
        Sesion::requerirAutenticacion();

        $error = null;
        $exito = null;
        $datos = [];

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
            $datos = $this->datosDesdePost();
            $error = Sesion::verifyCsrf($_POST['_csrf'] ?? null)
                ? $this->validar($datos)
                : 'La solicitud no es válida o ha vencido.';

            if ($error === null) {
                try {
                    $resultado = $this->repositorio->crear($datos);
                    if (($resultado['exito'] ?? false) === true) {
                        $exito = $resultado['mensaje'] ?? 'Expediente creado correctamente.';
                        $datos = [];
                    } else {
                        $error = $resultado['mensaje'] ?? 'No fue posible crear el expediente.';
                    }
                } catch (Throwable) {
                    $error = 'No fue posible crear el expediente.';
                }
            }
        }

        render('expedientes/formulario', [
            'title' => 'Crear expediente',
            'modo' => 'crear',
            'datos' => $datos,
            'error' => $error,
            'exito' => $exito,
            'csrf' => Sesion::csrfToken(),
        ]);
    }

    public function consultar(): void
    {
        Sesion::requerirAutenticacion();

        $id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
        $error = null;
        $expediente = null;

        if ($id === false || $id === null) {
            $error = 'Debe indicar un expediente válido.';
        } else {
            try {
                $expediente = $this->repositorio->consultar($id);
                if (($expediente['exito'] ?? false) !== true) {
                    $error = $expediente['mensaje'] ?? 'No se encontró el expediente.';
                    $expediente = null;
                }
            } catch (Throwable) {
                $error = 'No fue posible consultar el expediente.';
            }
        }

        render('expedientes/consultar', [
            'title' => 'Consultar expediente',
            'expediente' => $expediente,
            'error' => $error,
        ]);
    }

    public function editar(): void
    {
        Sesion::requerirAutenticacion();

        $id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
        $error = null;
        $exito = null;
        $datos = [];

        if ($id === false || $id === null) {
            $error = 'Debe indicar un expediente válido.';
        } else {
            if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
                $datos = $this->datosDesdePost();
                $datos['id'] = $id;
                $error = Sesion::verifyCsrf($_POST['_csrf'] ?? null)
                    ? $this->validar($datos)
                    : 'La solicitud no es válida o ha vencido.';

                if ($error === null) {
                    try {
                        $resultado = $this->repositorio->editar($datos);
                        if (($resultado['exito'] ?? false) === true) {
                            $exito = $resultado['mensaje'] ?? 'Expediente actualizado correctamente.';
                        } else {
                            $error = $resultado['mensaje'] ?? 'No fue posible actualizar el expediente.';
                        }
                    } catch (Throwable) {
                        $error = 'No fue posible actualizar el expediente.';
                    }
                }
            } else {
                try {
                    $resultado = $this->repositorio->consultar($id);
                    if (($resultado['exito'] ?? false) === true) {
                        $datos = $resultado['datos'] ?? [];
                    } else {
                        $error = $resultado['mensaje'] ?? 'No se encontró el expediente.';
                    }
                } catch (Throwable) {
                    $error = 'No fue posible cargar el expediente.';
                }
            }
        }

        render('expedientes/formulario', [
            'title' => 'Editar expediente',
            'modo' => 'editar',
            'datos' => $datos,
            'error' => $error,
            'exito' => $exito,
            'csrf' => Sesion::csrfToken(),
        ]);
    }

    private function datosDesdePost(): array
    {
        return [
            'idUsuario' => (string) ($_POST['idUsuario'] ?? ''),
            'numeroExpediente' => trim((string) ($_POST['numeroExpediente'] ?? '')),
            'nombreCompleto' => trim((string) ($_POST['nombreCompleto'] ?? '')),
            'estado' => trim((string) ($_POST['estado'] ?? '')),
            'observaciones' => trim((string) ($_POST['observaciones'] ?? '')),
        ];
    }

    private function validar(array $datos): ?string
    {
        if (($datos['idUsuario'] ?? '') === '') {
            return 'El usuario es obligatorio.';
        }
        if (filter_var($datos['idUsuario'], FILTER_VALIDATE_INT) === false || (int) $datos['idUsuario'] < 1) {
            return 'El usuario debe ser un identificador entero positivo.';
        }
        if (($datos['numeroExpediente'] ?? '') === '') {
            return 'El número de expediente es obligatorio.';
        }
        if (($datos['nombreCompleto'] ?? '') === '') {
            return 'El nombre completo es obligatorio.';
        }
        if (($datos['estado'] ?? '') === '') {
            return 'El estado es obligatorio.';
        }
        if (mb_strlen($datos['numeroExpediente']) > 50) {
            return 'El número de expediente no puede superar 50 caracteres.';
        }
        if (mb_strlen($datos['nombreCompleto']) > 150) {
            return 'El nombre completo no puede superar 150 caracteres.';
        }
        if (mb_strlen($datos['observaciones'] ?? '') > 1000) {
            return 'Las observaciones no pueden superar 1000 caracteres.';
        }

        return null;
    }
}
