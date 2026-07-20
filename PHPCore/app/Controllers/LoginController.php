<?php
declare(strict_types=1);
namespace App\Controllers;

use App\Core\Sesion;
use App\Repositories\AutenticacionRepository;
use Throwable;

final class LoginController
{
    public function mostrarLogin(): void
    {
        if (Sesion::estaAutenticado()) {
            redirect(url());
        }
        render('login', [
            'title' => 'Ingresar',
            'error' => Sesion::getFlash('error'),
            'usuario' => Sesion::getFlash('usuario', ''),
            'csrf' => Sesion::csrfToken(),
        ]);
    }

    public function procesarLogin(): void
    {
        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
            redirect(url('login'));
        }
        $usuario = trim((string) ($_POST['usuario'] ?? ''));
        $password = (string) ($_POST['password'] ?? '');
        Sesion::flash('usuario', $usuario);

        if (!Sesion::verifyCsrf($_POST['_csrf'] ?? null)) {
            http_response_code(419);
            render('errors/419', ['title' => 'Solicitud vencida']);
            return;
        }
        if ($usuario === '' || $password === '') {
            $this->rechazar();
        }

        try {
            $resultado = (new AutenticacionRepository())->autenticar($usuario, $password);
        } catch (Throwable) {
            Sesion::flash('error', 'No fue posible comunicarse con el servicio de autenticación.');
            redirect(url('login'));
        }
        if (!$resultado['exito']) {
            $this->rechazar();
        }

        Sesion::iniciarAutenticacion($resultado);
        redirect(url());
    }

    public function logout(): void
    {
        Sesion::cerrar();
        redirect(url('login'));
    }

    private function rechazar(): never
    {
        Sesion::flash('error', 'Usuario y/o contraseña incorrectos.');
        redirect(url('login'));
    }
}
