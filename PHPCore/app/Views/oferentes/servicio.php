<?php
/**
 * Vista de depuración del servicio de Oferentes (HU CORE2).
 *
 * CORE2 es un web service: su contrato real es JSON (ver
 * Oferentes_controller::oferentesPorPuesto()). Esta tabla solo se
 * muestra cuando la petición llega desde un navegador (Accept: text/html),
 * para poder revisar visualmente el mismo arreglo que devuelve el JSON,
 * con el mismo estilo de tabla que la pantalla de CORE7.
 *
 * Variables recibidas:
 *   string|null $error
 *   array       $oferentes     (arreglo completo, sin paginar)
 *   string|null $codigoPuesto
 */
?>

<h1>Oferentes por Puesto</h1>

<?php if ($error !== null): ?>
    <div class="alert alert-warning"><?= e($error) ?></div>

<?php else: ?>

    <p>Puesto: <strong><?= e($codigoPuesto) ?></strong></p>

    <?php if (empty($oferentes)): ?>
        <p>No se encontraron oferentes para este puesto.</p>
    <?php else: ?>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Nombre completo</th>
                    <th>Identificación</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($oferentes as $oferente): ?>
                <tr>
                    <td><?= e($oferente['nombre_completo']) ?></td>
                    <td><?= e($oferente['identificacion']) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>

<?php endif; ?>
