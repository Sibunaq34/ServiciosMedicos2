<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\SoapService;
use RuntimeException;
use Throwable;

final class ExpedientePersonalRepository
{
    public function listar(): array
    {
        try {
            $respuesta = (new SoapService(WebService::EXPEDIENTE_PERSONAL))->call('ListarExpedientes');
            return $this->normalizarLista($respuesta);
        } catch (Throwable) {
            throw new RuntimeException('No fue posible consultar los expedientes.');
        }
    }

    public function crear(array $datos): array
    {
        try {
            $respuesta = (new SoapService(WebService::EXPEDIENTE_PERSONAL))->call('CrearExpediente', [
                'idUsuario' => (int) ($datos['idUsuario'] ?? 0),
                'numeroExpediente' => (string) ($datos['numeroExpediente'] ?? ''),
                'nombreCompleto' => (string) ($datos['nombreCompleto'] ?? ''),
                'estado' => (string) ($datos['estado'] ?? ''),
                'observaciones' => (string) ($datos['observaciones'] ?? ''),
            ]);

            return $this->normalizarResultado($respuesta, 'Expediente creado correctamente.');
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible crear el expediente.'];
        }
    }

    public function consultar(int $id): array
    {
        try {
            $respuesta = (new SoapService(WebService::EXPEDIENTE_PERSONAL))->call('ConsultarExpediente', [
                'id' => $id,
            ]);

            return $this->normalizarResultado($respuesta, 'Expediente encontrado.', true);
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible consultar el expediente.'];
        }
    }

    public function editar(array $datos): array
    {
        try {
            $respuesta = (new SoapService(WebService::EXPEDIENTE_PERSONAL))->call('EditarExpediente', [
                'id' => (int) ($datos['id'] ?? 0),
                'idUsuario' => (int) ($datos['idUsuario'] ?? 0),
                'numeroExpediente' => (string) ($datos['numeroExpediente'] ?? ''),
                'nombreCompleto' => (string) ($datos['nombreCompleto'] ?? ''),
                'estado' => (string) ($datos['estado'] ?? ''),
                'observaciones' => (string) ($datos['observaciones'] ?? ''),
            ]);

            return $this->normalizarResultado($respuesta, 'Expediente actualizado correctamente.');
        } catch (Throwable) {
            return ['exito' => false, 'mensaje' => 'No fue posible actualizar el expediente.'];
        }
    }

    private function normalizarResultado(mixed $respuesta, string $mensajePredeterminada, bool $conDatos = false): array
    {
        if (is_object($respuesta) && property_exists($respuesta, 'ListarExpedientesResult')) {
            $respuesta = $respuesta->ListarExpedientesResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'CrearExpedienteResult')) {
            $respuesta = $respuesta->CrearExpedienteResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'ConsultarExpedienteResult')) {
            $respuesta = $respuesta->ConsultarExpedienteResult;
        } elseif (is_object($respuesta) && property_exists($respuesta, 'EditarExpedienteResult')) {
            $respuesta = $respuesta->EditarExpedienteResult;
        }

        $exito = filter_var($this->valor($respuesta, ['Exito', 'exito'], false), FILTER_VALIDATE_BOOL);
        $mensaje = (string) $this->valor($respuesta, ['Mensaje', 'mensaje'], $mensajePredeterminada);

        $datos = [];
        if ($conDatos) {
            $datos = $this->normalizarRegistro($respuesta);
        }

        return ['exito' => $exito, 'mensaje' => $mensaje, 'datos' => $datos];
    }

    private function normalizarLista(mixed $respuesta): array
    {
        if (is_object($respuesta) && property_exists($respuesta, 'ListarExpedientesResult')) {
            $respuesta = $respuesta->ListarExpedientesResult;
        }

        if (is_object($respuesta)) {
            $respuesta = [$respuesta];
        }

        if (!is_array($respuesta)) {
            return [];
        }

        return array_values(array_map(fn($item) => $this->normalizarRegistro($item), $respuesta));
    }

    private function normalizarRegistro(mixed $registro): array
    {
        if (!is_object($registro)) {
            return [];
        }

        return [
            'id' => (int) $this->valor($registro, ['Id', 'id'], 0),
            'idUsuario' => (string) $this->valor($registro, ['IdUsuario', 'idUsuario'], ''),
            'numeroExpediente' => (string) $this->valor($registro, ['NumeroExpediente', 'numeroExpediente'], ''),
            'nombreCompleto' => (string) $this->valor($registro, ['NombreCompleto', 'nombreCompleto'], ''),
            'estado' => (string) $this->valor($registro, ['Estado', 'estado'], ''),
            'observaciones' => (string) $this->valor($registro, ['Observaciones', 'observaciones'], ''),
        ];
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
