<section class="prototype-home">
    <div class="hero-panel mb-4">
        <div class="row align-items-center g-4">
            <div class="col-lg-8">
                <p class="section-kicker mb-2">Prototipo funcional</p>
                <h1 class="display-6 fw-semibold mb-3">Historias Core 3 y Core 9</h1>
                <p class="lead text-secondary mb-0">Interfaz para consultar el detalle de un oferente y simular su conversión en empleado. Todos los datos son demostrativos.</p>
            </div>
            <div class="col-lg-4 text-lg-end"><span class="demo-pill"><i class="bi bi-database-lock me-2"></i>Sin base de datos</span></div>
        </div>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-6"><article class="card story-card h-100"><div class="card-body p-4">
            <div class="story-icon mb-3"><i class="bi bi-person-vcard"></i></div><span class="badge text-bg-primary mb-2">CORE 9</span>
            <h2 class="h4">Detalle de Oferente</h2><p class="text-secondary">Información personal, contacto, estudios, experiencia, concurso y requisitos.</p>
            <a class="btn btn-primary" href="<?= e(url('detalle-oferente', ['id' => 1])) ?>">Abrir historia <i class="bi bi-arrow-right ms-1"></i></a>
        </div></article></div>
        <div class="col-md-6"><article class="card story-card h-100"><div class="card-body p-4">
            <div class="story-icon mb-3"><i class="bi bi-person-plus"></i></div><span class="badge text-bg-primary mb-2">CORE 3</span>
            <h2 class="h4">Crear Empleado</h2><p class="text-secondary">Reutiliza los datos del oferente, completa la contratación y simula el registro.</p>
            <a class="btn btn-primary" href="<?= e(url('crear-empleado', ['idOferente' => 1])) ?>">Abrir historia <i class="bi bi-arrow-right ms-1"></i></a>
        </div></article></div>
    </div>

    <div class="d-flex flex-column flex-sm-row justify-content-between align-items-sm-end gap-2 mb-3">
        <div><p class="section-kicker mb-1">Datos quemados</p><h2 class="h4 mb-0">Oferentes de demostración</h2></div>
        <span class="text-secondary small">Seleccione un nombre para ver Core 9</span>
    </div>
    <div class="card overflow-hidden"><div class="table-responsive"><table class="table align-middle">
        <thead><tr><th>Oferente</th><th>Identificación</th><th>Puesto</th><th>Estado</th><th class="text-end">Acción</th></tr></thead>
        <tbody>
        <?php foreach ([
            ['id' => 1, 'nombre' => 'Ana Rodríguez Pérez', 'identificacion' => '1-1111-1111', 'puesto' => 'Enfermero', 'estado' => 'Apto'],
            ['id' => 2, 'nombre' => 'Carlos Méndez Solís', 'identificacion' => '2-2222-2222', 'puesto' => 'Recepcionista', 'estado' => 'En revisión'],
            ['id' => 3, 'nombre' => 'Mariana Castro Vega', 'identificacion' => '3-3333-3333', 'puesto' => 'Asistente administrativa', 'estado' => 'Pendiente'],
        ] as $oferente): ?>
            <tr><td><a class="person-link" href="<?= e(url('detalle-oferente', ['id' => $oferente['id']])) ?>"><?= e($oferente['nombre']) ?></a></td>
                <td><?= e($oferente['identificacion']) ?></td><td><?= e($oferente['puesto']) ?></td>
                <td><span class="status-dot"></span><?= e($oferente['estado']) ?></td>
                <td class="text-end"><a class="btn btn-sm btn-outline-primary" href="<?= e(url('detalle-oferente', ['id' => $oferente['id']])) ?>">Ver detalle</a></td></tr>
        <?php endforeach; ?>
        </tbody>
    </table></div></div>
</section>
