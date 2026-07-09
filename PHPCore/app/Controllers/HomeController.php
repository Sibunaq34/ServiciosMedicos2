<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Sesion;

final class HomeController
{
    public function index(): void
    {
        render('index', [
            'title' => 'Bienvenido a Servicios Médicos',
        ]);
    }
    public function notFound(): void
    {
        http_response_code(404);
        render('errors/404', ['title' => 'Página no encontrada']);
    }
}
