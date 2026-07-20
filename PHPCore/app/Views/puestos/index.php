<div class="card shadow-sm border-0">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h1 class="h4 mb-0">Mantenimiento de puestos</h1>
        <a class="btn btn-primary btn-sm" href="<?= e(url('puestos-crear')) ?>">Crear puesto</a>
    </div>
    <div class="card-body">
        <?php if (!empty($error)): ?><div class="alert alert-danger"><?= e((string) $error) ?></div><?php endif; ?>
        <?php if (!empty($exito)): ?><div class="alert alert-success"><?= e((string) $exito) ?></div><?php endif; ?>
        <?php if (empty($error) && empty($puestos)): ?>
            <div class="alert alert-info mb-0">No hay puestos registrados.</div>
        <?php elseif (!empty($puestos)): ?>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead><tr><th>Código</th><th>Nombre</th><th>Estado</th><th class="text-end">Acciones</th></tr></thead>
                    <tbody>
                    <?php foreach ($puestos as $puesto): ?>
                        <?php $activo = strtolower((string) ($puesto['estado'] ?? '')) === 'activo'; ?>
                        <tr>
                            <td><?= e($puesto['codigoPuesto'] ?? '') ?></td>
                            <td><?= e($puesto['nombrePuesto'] ?? '') ?></td>
                            <td><span class="badge <?= $activo ? 'text-bg-success' : 'text-bg-secondary' ?>"><?= $activo ? 'Activo' : 'Inactivo' ?></span></td>
                            <td class="text-end text-nowrap">
                                <a class="btn btn-outline-secondary btn-sm" href="<?= e(url('puestos-consultar', ['id' => $puesto['id'] ?? 0])) ?>">Consultar</a>
                                <a class="btn btn-outline-primary btn-sm" href="<?= e(url('puestos-editar', ['id' => $puesto['id'] ?? 0])) ?>">Editar</a>
                                <form class="d-inline" method="post" action="<?= e(url('puestos-estado')) ?>" data-confirm="<?= e($activo ? '¿Confirma que desea inactivar este puesto?' : '¿Confirma que desea activar este puesto?') ?>">
                                    <input type="hidden" name="_csrf" value="<?= e(\App\Core\Sesion::csrfToken()) ?>">
                                    <input type="hidden" name="id" value="<?= (int) ($puesto['id'] ?? 0) ?>">
                                    <input type="hidden" name="estado" value="<?= $activo ? 'inactivo' : 'activo' ?>">
                                    <button class="btn btn-sm <?= $activo ? 'btn-outline-danger' : 'btn-outline-success' ?>" type="submit"><?= $activo ? 'Inactivar' : 'Activar' ?></button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</div>
