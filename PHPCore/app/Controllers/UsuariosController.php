<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;
use App\Repositories\UsuarioRepository;
use Throwable;

final class UsuariosController
{
    private UsuarioRepository $repositorio;

    public function __construct()
    {
        $this->repositorio = new UsuarioRepository();
    }

    public function index(): void
    {
        Sesion::requerirAutenticacion();

        try {
            $usuarios = $this->repositorio->listar();
            $error = null;
        } catch (Throwable) {
            $usuarios = [];
            $error = 'No fue posible consultar los usuarios.';
        }

        render('usuarios/index', [
            'title' => 'Usuarios',
            'usuarios' => $usuarios,
            'error' => $error ?? Sesion::getFlash('error'),
            'exito' => Sesion::getFlash('success'),
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
                ? $this->validar($datos, false)
                : 'La solicitud no es válida o ha vencido.';

            if ($error === null) {
                try {
                    $resultado = $this->repositorio->crear($datos);
                    if (($resultado['exito'] ?? false) === true) {
                        $exito = $resultado['mensaje'] ?? 'Usuario creado correctamente.';
                        $datos = [];
                    } else {
                        $error = $resultado['mensaje'] ?? 'No fue posible crear el usuario.';
                    }
                } catch (Throwable) {
                    $error = 'No fue posible crear el usuario.';
                }
            }
        }

        render('usuarios/formulario', [
            'title' => 'Crear usuario',
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
        $usuario = null;

        if ($id === false || $id === null) {
            $error = 'Debe indicar un usuario válido.';
        } else {
            try {
                $usuario = $this->repositorio->consultar($id);
                if (($usuario['exito'] ?? false) !== true) {
                    $error = $usuario['mensaje'] ?? 'No se encontró el usuario.';
                    $usuario = null;
                }
            } catch (Throwable) {
                $error = 'No fue posible consultar el usuario.';
            }
        }

        render('usuarios/consultar', [
            'title' => 'Consultar usuario',
            'usuario' => $usuario,
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
            $error = 'Debe indicar un usuario válido.';
        } else {
            if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
                $datos = $this->datosDesdePost();
                $datos['id'] = $id;
                $error = Sesion::verifyCsrf($_POST['_csrf'] ?? null)
                    ? $this->validar($datos, true)
                    : 'La solicitud no es válida o ha vencido.';

                if ($error === null) {
                    try {
                        $resultado = $this->repositorio->editar($datos);
                        if (($resultado['exito'] ?? false) === true) {
                            $exito = $resultado['mensaje'] ?? 'Usuario actualizado correctamente.';
                        } else {
                            $error = $resultado['mensaje'] ?? 'No fue posible actualizar el usuario.';
                        }
                    } catch (Throwable) {
                        $error = 'No fue posible actualizar el usuario.';
                    }
                }
            } else {
                try {
                    $resultado = $this->repositorio->consultar($id);
                    if (($resultado['exito'] ?? false) === true) {
                        $datos = $resultado['datos'] ?? [];
                    } else {
                        $error = $resultado['mensaje'] ?? 'No se encontró el usuario.';
                    }
                } catch (Throwable) {
                    $error = 'No fue posible cargar el usuario.';
                }
            }
        }

        render('usuarios/formulario', [
            'title' => 'Editar usuario',
            'modo' => 'editar',
            'datos' => $datos,
            'error' => $error,
            'exito' => $exito,
            'csrf' => Sesion::csrfToken(),
        ]);
    }

    public function cambiarEstado(): void
    {
        Sesion::requerirAutenticacion();

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST' || !Sesion::verifyCsrf($_POST['_csrf'] ?? null)) {
            Sesion::flash('error', 'La solicitud no es válida o ha vencido.');
            redirect(url('usuarios'));
        }

        $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
        $estado = strtolower(trim((string) ($_POST['estado'] ?? '')));

        if ($id === false || $id === null || ($estado !== 'activo' && $estado !== 'inactivo')) {
            redirect(url('usuarios'));
            return;
        }

        try {
            $resultado = $this->repositorio->cambiarEstado($id, $estado);
        } catch (Throwable) {
            $resultado = ['exito' => false, 'mensaje' => 'No fue posible cambiar el estado del usuario.'];
        }

        Sesion::flash($resultado['exito'] ? 'success' : 'error', $resultado['mensaje'] ?? 'Operación realizada.');
        redirect(url('usuarios'));
    }

    private function datosDesdePost(): array
    {
        return [
            'usuario' => trim((string) ($_POST['usuario'] ?? '')),
            'password' => (string) ($_POST['password'] ?? ''),
            'nombreCompleto' => trim((string) ($_POST['nombreCompleto'] ?? '')),
            'correo' => trim((string) ($_POST['correo'] ?? '')),
            'rol' => trim((string) ($_POST['rol'] ?? '')),
            'estado' => trim((string) ($_POST['estado'] ?? '')),
        ];
    }

    private function validar(array $datos, bool $edicion): ?string
    {
        if (($datos['usuario'] ?? '') === '') {
            return 'El usuario es obligatorio.';
        }
        if (!$edicion && ($datos['password'] ?? '') === '') {
            return 'La contraseña es obligatoria.';
        }
        if (($datos['password'] ?? '') !== '' && strlen($datos['password']) < 8) {
            return 'La contraseña debe tener al menos 8 caracteres.';
        }
        if (($datos['nombreCompleto'] ?? '') === '') {
            return 'El nombre completo es obligatorio.';
        }
        if (($datos['correo'] ?? '') === '') {
            return 'El correo es obligatorio.';
        }
        if (!filter_var($datos['correo'], FILTER_VALIDATE_EMAIL) || strlen($datos['correo']) > 150) {
            return 'Debe indicar un correo válido de máximo 150 caracteres.';
        }
        if (mb_strlen($datos['usuario']) > 50 || mb_strlen($datos['nombreCompleto']) > 150) {
            return 'El usuario admite máximo 50 caracteres y el nombre máximo 150.';
        }
        if (($datos['rol'] ?? '') === '') {
            return 'El rol es obligatorio.';
        }
        if (($datos['estado'] ?? '') === '') {
            return 'El estado es obligatorio.';
        }
        if (!in_array(strtolower($datos['estado']), ['activo', 'inactivo'], true)) {
            return 'El estado seleccionado no es válido.';
        }

        return null;
    }
}
