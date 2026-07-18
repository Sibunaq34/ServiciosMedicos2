<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\DetalleOferenteRepository;

final class DetalleOferenteController
{
    private DetalleOferenteRepository $repositorio;

    public function __construct(?DetalleOferenteRepository $repositorio = null)
    {
        $this->repositorio = $repositorio ?? new DetalleOferenteRepository();
    }

    public function detalle(): void
    {
        // Persona C - Kenneth
        // Valida el identificador antes de delegar la consulta al repository.
        $idOferente = $this->obtenerIdOferente();
        $detalle = null;
        $error = null;
        $integracionPendiente = false;

        if ($idOferente === null) {
            $error = 'El parámetro idOferente es requerido y debe ser un entero positivo.';
        } else {
            $resultado = $this->repositorio->obtenerDetalle($idOferente);
            $detalle = is_array($resultado['datos'] ?? null) ? $resultado['datos'] : null;
            $error = is_string($resultado['mensaje'] ?? null) ? $resultado['mensaje'] : null;
            $integracionPendiente = ($resultado['exito'] ?? false) === false && $detalle === null;
        }

        render('oferentes/detalle-core8', [
            'title' => 'Detalle completo de oferente',
            'idOferente' => $idOferente,
            'detalle' => $detalle,
            'error' => $error,
            'integracionPendiente' => $integracionPendiente,
        ]);
    }

    private function obtenerIdOferente(): ?int
    {
        $valor = filter_input(INPUT_GET, 'idOferente');

        if (!is_string($valor)) {
            return null;
        }

        $valor = trim($valor);

        if ($valor === '' || !preg_match('/^[1-9][0-9]*$/', $valor)) {
            return null;
        }

        $idOferente = filter_var($valor, FILTER_VALIDATE_INT);

        if ($idOferente === false || $idOferente < 1) {
            return null;
        }

        return $idOferente;
    }
}
