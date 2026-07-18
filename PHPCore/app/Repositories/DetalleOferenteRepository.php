<?php

declare(strict_types=1);

namespace App\Repositories;

final class DetalleOferenteRepository
{
    public function obtenerDetalle(int $idOferente): array
    {
        // Persona C - Kenneth
        // Integracion SOAP pendiente del WSDL y la operacion definitiva de CORE8.
        return [
            'exito' => false,
            'datos' => null,
            'mensaje' => 'El servicio de detalle de oferente está pendiente de integración.',
        ];
    }
}
