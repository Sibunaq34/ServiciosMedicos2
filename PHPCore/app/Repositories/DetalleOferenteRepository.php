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
            'id_persona' => $this->valor($datos, 'IdPersona'),
            'identificacion' => $this->valor($datos, 'Identificacion'),
            'tipo_identificacion' => $this->valor($datos, 'TipoIdentificacion'),
            'nombre_completo' => $this->valor($datos, 'NombreCompleto'),
            'fecha_nacimiento' => $this->fecha($this->valor($datos, 'FechaNacimiento')),
            'fecha_registro' => $this->fecha($this->valor($datos, 'FechaRegistro')),
            'correos' => $this->normalizarLista($datos->Correos ?? null, 'string'),
            'telefonos' => $this->normalizarLista($datos->Telefonos ?? null, 'string'),
            'preparacion_academica' => array_map(
                fn(object $item): array => $this->normalizarPreparacion($item),
                $this->normalizarLista($datos->PreparacionAcademica ?? null, 'PreparacionAcademicaDetalleCore8')
            ),
            'experiencia_laboral' => array_map(
                fn(object $item): array => $this->normalizarExperiencia($item),
                $this->normalizarLista($datos->ExperienciaLaboral ?? null, 'ExperienciaLaboralDetalleCore8')
            ),
            'participaciones' => array_map(
                fn(object $item): array => $this->normalizarParticipacion($item),
                $this->normalizarLista($datos->Participaciones ?? null, 'ParticipacionConcursoDetalleCore8')
            ),
        ];
    }

    private function normalizarPreparacion(object $item): array
    {
        return [
            'codigo_institucion' => $this->valor($item, 'CodigoInstitucion'),
            'institucion' => $this->valor($item, 'NombreInstitucion'),
            'titulo' => $this->valor($item, 'Titulo'),
            'fecha_inicio' => $this->fecha($this->valor($item, 'FechaInicio')),
            'fecha_fin' => $this->fecha($this->valor($item, 'FechaFin')),
        ];
    }

    private function normalizarExperiencia(object $item): array
    {
        return [
            'empresa' => $this->valor($item, 'NombreEmpresa'),
            'puesto' => $this->valor($item, 'PuestoDesempenado'),
            'fecha_inicio' => $this->fecha($this->valor($item, 'FechaInicio')),
            'fecha_fin' => $this->fecha($this->valor($item, 'FechaFin')),
        ];
    }

    private function normalizarParticipacion(object $item): array
    {
        return [
            'codigo_concurso' => $this->valor($item, 'CodigoConcurso'),
            'nombre_concurso' => $this->valor($item, 'NombreConcurso'),
            'estado' => $this->valor($item, 'Estado'),
            'fecha_inicio' => $this->fecha($this->valor($item, 'FechaInicio')),
            'fecha_fin' => $this->fecha($this->valor($item, 'FechaFin')),
            'fecha_asignacion' => $this->fecha($this->valor($item, 'FechaAsignacion')),
        ];
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
