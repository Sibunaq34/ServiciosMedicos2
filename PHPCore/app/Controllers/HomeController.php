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
    public function detalleOferente(): void
    {
        // Muestra la pantalla CORE9.
        render('core9/detalle-oferente', [
            'title' => 'Detalle de Oferente',
            // JS propio de CORE9.
            'scripts' => [
                'public/assets/js/core9-detalle-oferente.js',
            ],
        ]);
    }

    public function crearEmpleado(): void
    {
        // Muestra la pantalla CORE3.
        render('core3/crear-empleado', [
            'title' => 'Crear Empleado',
            // JS propio de CORE3.
            'scripts' => [
                'public/assets/js/core3-crear-empleado.js',
            ],
        ]);
    }

    public function notFound(): void
    {
        http_response_code(404);
        render('errors/404', ['title' => 'Página no encontrada']);
    }
}
