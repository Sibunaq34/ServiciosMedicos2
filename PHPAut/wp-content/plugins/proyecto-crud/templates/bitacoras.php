<?php

if (empty($bitacoras)) {
    echo "<p>No existen registros.</p>";
    return;
}
?>

<table border="1" cellpadding="8">

    <tr>

        <th>ID</th>
        <th>Fecha</th>
        <th>Usuario</th>
        <th>Acción</th>
        <th>Descripción</th>

    </tr>

<?php foreach ($bitacoras as $fila): ?>

<tr>

    <td><?= $fila['id_bitacoras']; ?></td>

    <td><?= $fila['fecha_bitacora']; ?></td>

    <td><?= $fila['usuario']; ?></td>

    <td><?= $fila['accion']; ?></td>

    <td><?= $fila['descripcionAccion']; ?></td>

</tr>

<?php endforeach; ?>

</table>