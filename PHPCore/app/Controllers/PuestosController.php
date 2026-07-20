<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;
use App\Repositories\PuestoRepository;
use Throwable;

final class PuestosController
{
    private PuestoRepository $repositorio;

    public function __construct()
    {
        $this->repositorio = new PuestoRepository();
    }

    public function index(): void
    {
        Sesion::requerirAutenticacion();

        try {
            $puestos = $this->repositorio->listar();
            usort($puestos, static fn (array $a, array $b): int => strcasecmp($a['nombrePuesto'], $b['nombrePuesto']));
            $error = null;
        } catch (Throwable) {
            $puestos = [];
            $error = 'No fue posible consultar los puestos.';
        }

        render('puestos/index', [
            'title' => 'Mantenimiento de puestos',
            'puestos' => $puestos,
            'error' => $error ?? Sesion::getFlash('error'),
            'exito' => Sesion::getFlash('success'),
        ]);
    }

    public function crear(): void
    {
        Sesion::requerirAutenticacion();
        $this->formulario(null);
    }

    public function consultar(): void
    {
        Sesion::requerirAutenticacion();
        $id = $this->idDesdeGet();
        $resultado = $id === null
            ? ['exito' => false, 'mensaje' => 'Debe indicar un puesto válido.']
            : $this->repositorio->consultar($id);

        render('puestos/consultar', [
            'title' => 'Consultar puesto',
            'puesto' => ($resultado['exito'] ?? false) ? ($resultado['datos'] ?? []) : null,
            'error' => ($resultado['exito'] ?? false) ? null : ($resultado['mensaje'] ?? 'No se encontró el puesto.'),
        ]);
    }

    public function editar(): void
    {
        Sesion::requerirAutenticacion();
        $id = $this->idDesdeGet();

        if ($id === null) {
            render('puestos/formulario', [
                'title' => 'Editar puesto',
                'modo' => 'editar',
                'datos' => [],
                'error' => 'Debe indicar un puesto válido.',
                'exito' => null,
                'csrf' => Sesion::csrfToken(),
            ]);
            return;
        }

        $this->formulario($id);
    }

    public function cambiarEstado(): void
    {
        Sesion::requerirAutenticacion();

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST' || !Sesion::verifyCsrf($_POST['_csrf'] ?? null)) {
            Sesion::flash('error', 'La solicitud no es válida o ha vencido.');
            redirect(url('puestos'));
        }

        $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
        $estado = strtolower(trim((string) ($_POST['estado'] ?? '')));
        if ($id === false || $id < 1 || !in_array($estado, ['activo', 'inactivo'], true)) {
            Sesion::flash('error', 'Los datos para cambiar el estado no son válidos.');
            redirect(url('puestos'));
        }

        $resultado = $this->repositorio->cambiarEstado($id, $estado);
        Sesion::flash(($resultado['exito'] ?? false) ? 'success' : 'error', $resultado['mensaje'] ?? 'Operación realizada.');
        redirect(url('puestos'));
    }

    private function formulario(?int $id): void
    {
        $modo = $id === null ? 'crear' : 'editar';
        $datos = [];
        $error = null;
        $exito = null;

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
            $datos = $this->datosDesdePost();
            if ($id !== null) {
                $datos['id'] = $id;
            }
            if (!Sesion::verifyCsrf($_POST['_csrf'] ?? null)) {
                $error = 'La solicitud no es válida o ha vencido.';
            } else {
                $error = $this->validar($datos);
            }
            if ($error === null) {
                $resultado = $id === null ? $this->repositorio->crear($datos) : $this->repositorio->editar($datos);
                if (($resultado['exito'] ?? false) === true) {
                    $exito = $resultado['mensaje'];
                    if ($id === null) {
                        $datos = [];
                    }
                } else {
                    $error = $resultado['mensaje'] ?? 'No fue posible guardar el puesto.';
                }
            }
        } elseif ($id !== null) {
            $resultado = $this->repositorio->consultar($id);
            if (($resultado['exito'] ?? false) === true) {
                $datos = $resultado['datos'];
            } else {
                $error = $resultado['mensaje'] ?? 'No se encontró el puesto.';
            }
        }

        render('puestos/formulario', compact('modo', 'datos', 'error', 'exito') + [
            'title' => $id === null ? 'Crear puesto' : 'Editar puesto',
            'csrf' => Sesion::csrfToken(),
        ]);
    }

    private function datosDesdePost(): array
    {
        return [
            'codigoPuesto' => trim((string) ($_POST['codigoPuesto'] ?? '')),
            'nombrePuesto' => trim((string) ($_POST['nombrePuesto'] ?? '')),
            'descripcion' => trim((string) ($_POST['descripcion'] ?? '')),
            'estado' => strtolower(trim((string) ($_POST['estado'] ?? 'activo'))),
        ];
    }

    private function validar(array $datos): ?string
    {
        if (!preg_match('/^[A-Za-z0-9-]{1,20}$/', $datos['codigoPuesto'] ?? '')) {
            return 'El código es obligatorio, admite letras, números y guiones, y debe tener máximo 20 caracteres.';
        }
        $longitudNombre = mb_strlen($datos['nombrePuesto'] ?? '');
        if ($longitudNombre < 2 || $longitudNombre > 150) {
            return 'El nombre es obligatorio y debe tener entre 2 y 150 caracteres.';
        }
        if (mb_strlen($datos['descripcion'] ?? '') > 500) {
            return 'La descripción no puede superar 500 caracteres.';
        }
        if (!in_array($datos['estado'] ?? '', ['activo', 'inactivo'], true)) {
            return 'El estado seleccionado no es válido.';
        }

        return null;
    }

    private function idDesdeGet(): ?int
    {
        $id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
        return is_int($id) && $id > 0 ? $id : null;
    }
}
