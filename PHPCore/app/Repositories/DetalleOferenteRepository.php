<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Config\WebService;
use App\Core\SoapService;
use RuntimeException;

final class DetalleOferenteRepository
{
    public function obtenerDetalle(int $idOferente): array
    {
        if ($idOferente <= 0) {
            throw new RuntimeException('El identificador del oferente no es válido.');
        }

        $respuesta = (new SoapService(WebService::DETALLE_OFERENTE))
            ->call('ObtenerDetalleOferente', ['idOferente' => $idOferente]);

        $resultado = $respuesta->ObtenerDetalleOferenteResult ?? null;

        if (!is_object($resultado)) {
            throw new RuntimeException('El servicio de oferentes devolvió una respuesta inválida.');
        }

        return [
            'exito' => (bool) ($resultado->Exito ?? false),
            'mensaje' => (string) ($resultado->Mensaje ?? ''),
            'datos' => isset($resultado->Datos)
                ? $this->normalizar($resultado->Datos)
                : null,
        ];
    }

    private function normalizar(object $datos): array
    {
        return [
            'idOferente' => (int) ($datos->IdOferente ?? 0),
            'idPersona' => (int) ($datos->IdPersona ?? 0),
            'identificacion' => (string) ($datos->Identificacion ?? ''),
            'tipoIdentificacion' => (string) ($datos->TipoIdentificacion ?? ''),
            'nombreCompleto' => (string) ($datos->NombreCompleto ?? ''),
            'fechaNacimiento' => (string) ($datos->FechaNacimiento ?? ''),
            'fechaRegistro' => (string) ($datos->FechaRegistro ?? ''),
            'correos' => $this->lista($datos->Correos ?? null),
            'telefonos' => $this->lista($datos->Telefonos ?? null),
            'preparacionAcademica' => $this->lista($datos->PreparacionAcademica ?? null),
            'experienciaLaboral' => $this->lista($datos->ExperienciaLaboral ?? null),
            'participaciones' => $this->lista($datos->Participaciones ?? null),
        ];
    }

    private function lista(mixed $valor): array
    {
        if ($valor === null) {
            return [];
        }

        $elementos = is_array($valor)
            ? $valor
            : (array) ($valor->string ?? $valor->PreparacionAcademicaDetalleCore8 ??
                $valor->ExperienciaLaboralDetalleCore8 ??
                $valor->ParticipacionConcursoDetalleCore8 ?? []);

        return array_map(
            static fn(mixed $item): mixed => is_object($item) ? (array) $item : $item,
            $elementos
        );
    }
}
