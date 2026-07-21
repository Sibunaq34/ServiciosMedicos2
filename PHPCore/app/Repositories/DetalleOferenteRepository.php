<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\ServicioSoap;
use SoapFault;
use Throwable;

final class DetalleOferenteRepository
{
    public function obtenerDetalle(int $idOferente): array
    {
        // Persona C - Kenneth
        // Consulta el detalle del oferente mediante el servicio SOAP de CORE8.
        try {
            $soap = new ServicioSoap(WebService::DETALLE_OFERENTE);
            $respuesta = $soap->call('ObtenerDetalleOferente', [
                'idOferente' => $idOferente,
            ]);

            return $this->normalizarRespuesta($respuesta);
        } catch (SoapFault) {
            return [
                'exito' => false,
                'datos' => null,
                'mensaje' => 'El servicio de detalle de oferente no esta disponible en este momento.',
            ];
        } catch (Throwable) {
            return [
                'exito' => false,
                'datos' => null,
                'mensaje' => 'No fue posible procesar la respuesta del servicio de detalle de oferente.',
            ];
        }
    }

    private function normalizarRespuesta(mixed $respuesta): array
    {
        $resultado = is_object($respuesta)
            ? ($respuesta->ObtenerDetalleOferenteResult ?? null)
            : null;

        if (!is_object($resultado)) {
            return [
                'exito' => false,
                'datos' => null,
                'mensaje' => 'El servicio devolvio una respuesta inesperada.',
            ];
        }

        $exito = (bool) ($resultado->Exito ?? false);
        $mensaje = is_scalar($resultado->Mensaje ?? null)
            ? (string) $resultado->Mensaje
            : '';
        $datos = $resultado->Datos ?? null;

        return [
            'exito' => $exito,
            'datos' => $exito && is_object($datos) ? $this->normalizarDetalle($datos) : null,
            'mensaje' => $mensaje,
        ];
    }

    private function normalizarDetalle(object $datos): array
    {
        return [
            'id_oferente' => $this->valor($datos, 'IdOferente'),
            'identificacion' => $this->valor($datos, 'Identificacion'),
            'tipo_identificacion' => $this->valor($datos, 'TipoIdentificacion'),
            'nombre_completo' => $this->valor($datos, 'NombreCompleto'),
            'fecha_nacimiento' => $this->fecha($this->valor($datos, 'FechaNacimiento')),
            'correos' => $this->normalizarLista($datos->Correos ?? null, 'string'),
            'telefonos' => $this->normalizarLista($datos->Telefonos ?? null, 'string'),
            'puesto' => $this->normalizarPuesto($datos->Puesto ?? null),
            'curriculum' => $this->normalizarCurriculum($datos->Curriculum ?? null),
        ];
    }

    private function normalizarPuesto(mixed $item): ?array
    {
        if (!is_object($item)) {
            return null;
        }

        $codigo = $this->valor($item, 'CodigoPuesto');
        $nombre = $this->valor($item, 'NombrePuesto');

        if ($codigo === '' && $nombre === '') {
            return null;
        }

        return [
            'codigo_puesto' => $codigo,
            'nombre_puesto' => $nombre,
        ];
    }

    private function normalizarCurriculum(mixed $item): ?array
    {
        if (!is_object($item)) {
            return null;
        }

        $nombre = $this->valor($item, 'NombreArchivo');
        $mime = $this->valor($item, 'Mime');
        $tamanio = $this->entero($item, 'Tamanio');

        if ($nombre === '' && $mime === '' && $tamanio === 0) {
            return null;
        }

        return [
            'nombre_archivo' => $nombre,
            'mime' => $mime,
            'tamanio' => $tamanio,
            'tamanio_formateado' => $this->formatearBytes($tamanio),
        ];
    }

    private function entero(object $objeto, string $propiedad): int
    {
        $valor = $objeto->{$propiedad} ?? 0;

        return is_numeric($valor) ? max(0, (int) $valor) : 0;
    }

    private function formatearBytes(int $bytes): string
    {
        if ($bytes <= 0) {
            return '';
        }

        if ($bytes < 1024) {
            return $bytes . ' B';
        }

        if ($bytes < 1048576) {
            return number_format($bytes / 1024, 1) . ' KB';
        }

        return number_format($bytes / 1048576, 1) . ' MB';
    }

    /**
     * @return array<int, mixed>
     */
    private function normalizarLista(mixed $contenedor, string $propiedad): array
    {
        if ($contenedor === null) {
            return [];
        }

        if (is_array($contenedor)) {
            return array_values($contenedor);
        }

        if (is_object($contenedor)) {
            $valor = $contenedor->{$propiedad} ?? null;

            if ($valor === null) {
                return [];
            }

            return is_array($valor) ? array_values($valor) : [$valor];
        }

        return [$contenedor];
    }

    private function valor(object $objeto, string $propiedad): string
    {
        $valor = $objeto->{$propiedad} ?? '';

        return is_scalar($valor) ? (string) $valor : '';
    }

    private function fecha(string $valor): string
    {
        if ($valor === '') {
            return '';
        }

        $timestamp = strtotime($valor);

        return $timestamp === false ? $valor : date('Y-m-d', $timestamp);
    }
}
