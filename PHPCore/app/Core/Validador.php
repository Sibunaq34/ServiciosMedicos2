<?php

declare(strict_types=1);

namespace App\Core;


final class Validador
{
    /**
     
     * @return string|null El valor limpio, o null si no es válido.
     */
    public static function codigoPuesto(?string $valor): ?string
    {
        if ($valor === null) {
            return null;
        }

        $valor = trim($valor);

        if ($valor === '') {
            return null;
        }

        $valor = filter_var($valor, FILTER_SANITIZE_FULL_SPECIAL_CHARS);

        if ($valor === false || !preg_match('/^[A-Za-z0-9\-]{1,20}$/', $valor)) {
            return null;
        }

        return $valor;
    }

    /**
     * Valida el número de página recibido por GET.
     * Si no viene, viene inválido o es menor a 1, retorna 1 por defecto.
     */
    public static function pagina(mixed $valor): int
    {
        $pagina = filter_var($valor, FILTER_VALIDATE_INT);

        if ($pagina === false || $pagina < 1) {
            return 1;
        }

        return $pagina;
    }

    public static function idPositivo(mixed $valor): ?int
    {
        $id = filter_var($valor, FILTER_VALIDATE_INT);

        return $id !== false && $id > 0 ? $id : null;
    }
}
