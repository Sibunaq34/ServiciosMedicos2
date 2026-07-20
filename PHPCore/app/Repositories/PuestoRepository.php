<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\SoapService;
use RuntimeException;
use Throwable;

final class PuestoRepository
{
    public function listar(): array
    {
        try {
            return $this->normalizarLista($this->servicio()->call('ListarPuestos'));
        } catch (Throwable $exception) {
            throw new RuntimeException('No fue posible consultar los puestos.', 0, $exception);
        }
    }

    public function listarActivos(): array
    {
        try {
            return $this->normalizarLista($this->servicio()->call('ListarPuestosActivos'));
        } catch (Throwable $exception) {
            throw new RuntimeException('No fue posible consultar los puestos activos.', 0, $exception);
        }
    }

    public function crear(array $datos): array
    {
        return $this->ejecutar('CrearPuesto', [
            'codigoPuesto' => (string) ($datos['codigoPuesto'] ?? ''),
            'nombrePuesto' => (string) ($datos['nombrePuesto'] ?? ''),
            'descripcion' => (string) ($datos['descripcion'] ?? ''),
            'estado' => (string) ($datos['estado'] ?? 'activo'),
        ], 'Puesto creado correctamente.');
    }

    public function consultar(int $id): array
    {
        return $this->ejecutar('ConsultarPuesto', ['id' => $id], 'Puesto encontrado.', true);
    }

    public function editar(array $datos): array
    {
        return $this->ejecutar('EditarPuesto', [
            'id' => (int) ($datos['id'] ?? 0),
            'codigoPuesto' => (string) ($datos['codigoPuesto'] ?? ''),
            'nombrePuesto' => (string) ($datos['nombrePuesto'] ?? ''),
            'descripcion' => (string) ($datos['descripcion'] ?? ''),
            'estado' => (string) ($datos['estado'] ?? ''),
        ], 'Puesto actualizado correctamente.');
    }

    public function cambiarEstado(int $id, string $estado): array
    {
        return $this->ejecutar(
            'CambiarEstadoPuesto',
            ['id' => $id, 'estado' => $estado],
            'Estado del puesto actualizado correctamente.'
        );
    }

    private function servicio(): SoapService
    {
        return new SoapService(WebService::PUESTOS_WSDL);
    }

    private function ejecutar(
        string $operacion,
        array $parametros,
        string $mensajePredeterminado,
        bool $conDatos = false
    ): array {
        try {
            $respuesta = $this->desenvolver($this->servicio()->call($operacion, $parametros));
            $exito = filter_var($this->valor($respuesta, ['Exito', 'exito'], false), FILTER_VALIDATE_BOOL);
            $mensaje = (string) $this->valor(
                $respuesta,
                ['Mensaje', 'mensaje'],
                $exito ? $mensajePredeterminado : 'El servicio rechazó la operación.'
            );

            return [
                'exito' => $exito,
                'mensaje' => $mensaje,
                'datos' => $conDatos ? $this->normalizarRegistro($respuesta) : [],
            ];
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible completar la operación con el servicio de puestos.'];
        }
    }

    private function normalizarLista(mixed $respuesta): array
    {
        $respuesta = $this->desenvolver($respuesta);

        if (is_object($respuesta)) {
            $propiedades = get_object_vars($respuesta);
            if (count($propiedades) === 1) {
                $respuesta = reset($propiedades);
            }
        }
        if (is_object($respuesta)) {
            $respuesta = [$respuesta];
        }
        if (!is_array($respuesta)) {
            return [];
        }
        if (!array_is_list($respuesta)) {
            $respuesta = [$respuesta];
        }

        return array_values(array_filter(array_map(
            fn (mixed $registro): array => $this->normalizarRegistro($registro),
            $respuesta
        ), static fn (array $registro): bool => $registro['id'] > 0 || $registro['codigoPuesto'] !== ''));
    }

    private function normalizarRegistro(mixed $registro): array
    {
        return [
            'id' => (int) $this->valor($registro, ['Id', 'IdPuesto', 'id', 'idPuesto'], 0),
            'codigoPuesto' => (string) $this->valor($registro, ['CodigoPuesto', 'codigoPuesto'], ''),
            'nombrePuesto' => (string) $this->valor($registro, ['NombrePuesto', 'nombrePuesto'], ''),
            'descripcion' => (string) $this->valor($registro, ['Descripcion', 'descripcion'], ''),
            'estado' => strtolower((string) $this->valor($registro, ['Estado', 'estado'], 'activo')),
        ];
    }

    private function desenvolver(mixed $respuesta): mixed
    {
        while (is_object($respuesta) && count(get_object_vars($respuesta)) === 1) {
            $respuesta = reset($respuesta);
        }
        while (is_array($respuesta) && count($respuesta) === 1 && !array_is_list($respuesta)) {
            $respuesta = reset($respuesta);
        }

        return $respuesta;
    }

    private function valor(mixed $origen, array $nombres, mixed $predeterminado): mixed
    {
        foreach ($nombres as $nombre) {
            if (is_object($origen) && property_exists($origen, $nombre)) {
                return $origen->{$nombre};
            }
            if (is_array($origen) && array_key_exists($nombre, $origen)) {
                return $origen[$nombre];
            }
        }

        return $predeterminado;
    }
}
