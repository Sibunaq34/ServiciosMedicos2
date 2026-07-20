<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\ServicioSoap;
use RuntimeException;

final class EmpleadoRepository
{
    public function oferenteEsEmpleado(int $idOferente): bool
    {
        if ($idOferente <= 0) {
            return false;
        }

        $respuesta = (new ServicioSoap(WebService::EMPLEADOS))
            ->call('OferenteEsEmpleado', ['idOferente' => $idOferente]);

        return (bool) ($respuesta->OferenteEsEmpleadoResult ?? false);
    }

    public function registrar(array $solicitud): array
    {
        foreach (['IdOferente', 'IdUsuario'] as $campo) {
            if (!isset($solicitud[$campo]) || (int) $solicitud[$campo] <= 0) {
                throw new RuntimeException('La solicitud para registrar el empleado está incompleta.');
            }
        }

        if (empty($solicitud['CodigoPuesto'])) {
            throw new RuntimeException('El código de puesto es requerido.');
        }

        $respuesta = (new ServicioSoap(WebService::EMPLEADOS))
            ->call('RegistrarEmpleado', ['entrada' => $solicitud]);

        $resultado = $this->extraer($respuesta, 'RegistrarEmpleadoResult');

        if ($resultado === null) {
            throw new RuntimeException('El servicio de empleados devolvió una respuesta inválida.');
        }

        if (is_array($resultado)) {
            $resultado = (object) $resultado;
        }

        if (!is_object($resultado)) {
            throw new RuntimeException('El servicio de empleados devolvió una respuesta inválida.');
        }

        return [
            'exito' => (bool) ($resultado->Exito ?? false),
            'codigo' => (string) ($resultado->Codigo ?? 'INTERNAL_ERROR'),
            'mensaje' => (string) ($resultado->Mensaje ?? 'No fue posible crear el empleado.'),
            'idEmpleado' => isset($resultado->IdEmpleado) ? (int) $resultado->IdEmpleado : null,
            'numeroEmpleado' => (string) ($resultado->NumeroEmpleado ?? ''),
        ];
    }

    /**
     * @param mixed $respuesta
     */
    private function extraer(mixed $respuesta, string $propiedad): mixed
    {
        if (is_object($respuesta) && property_exists($respuesta, $propiedad)) {
            return $respuesta->{$propiedad};
        }

        if (is_array($respuesta) && array_key_exists($propiedad, $respuesta)) {
            return $respuesta[$propiedad];
        }

        if (is_object($respuesta) && count(get_object_vars($respuesta)) === 1) {
            $propiedades = get_object_vars($respuesta);
            return reset($propiedades);
        }

        return $respuesta;
    }
}
