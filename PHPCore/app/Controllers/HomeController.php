<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;

final class HomeController
{
    public function index(): void
    {
        Sesion::requerirAutenticacion();
        $usuario = Sesion::usuario();

        render('index', [
            'nombreCompleto' => $usuario['nombre_completo'] ?? '',
            'title' => 'Bienvenido a Servicios Médicos',
        ]);
    }
    public function notFound(): void
    {
        http_response_code(404);
        render('errors/404', ['title' => 'Página no encontrada']);
    }
}
