<?php

declare(strict_types=1);

$idOferente = filter_input(INPUT_GET, 'id', FILTER_UNSAFE_RAW);
// Valida ID sin modificarlo.
$idValido = is_string($idOferente) && preg_match('/^[1-9][0-9]*$/', $idOferente) === 1;
?>

<?php // Contenedor principal de CORE9. ?>
<section
    class="oferente-detalle"
    data-core9-detalle
    data-oferente-id="<?= e($idValido ? $idOferente : '') ?>"
    data-json-url="public/data/oferentes.json"
    data-crear-empleado-url="<?= e(url('crear-empleado')) ?>"
    data-cancelar-url="<?= e(url('index')) ?>"
>
    <div class="d-flex flex-column flex-md-row justify-content-between gap-3 align-items-md-center mb-4">
        <div>
            <p class="section-kicker mb-2">CORE9</p>
            <h1 class="h3 mb-1">Detalle de Oferente</h1>
            <p class="text-secondary mb-0">Revision de la informacion registrada para el oferente seleccionado.</p>
        </div>
        <a class="btn btn-outline-primary" href="<?= e(url('index')) ?>">
            <i class="bi bi-arrow-left me-1" aria-hidden="true"></i>
            Cancelar
        </a>
    </div>

    <?php // Estado: parametro invalido. ?>
    <div
        class="alert alert-danger d-none"
        role="alert"
        data-parametro-invalido
    >
        No se proporciono un oferente valido.
    </div>

    <?php // Estado: cargando datos. ?>
    <div
        class="alert alert-info d-flex align-items-center gap-2"
        aria-live="polite"
        data-estado-carga
    >
        <span class="spinner-border spinner-border-sm" aria-hidden="true"></span>
        <span>Cargando informacion del oferente...</span>
    </div>

    <?php // Estado: error de carga. ?>
    <div
        class="alert alert-danger d-none"
        role="alert"
        data-estado-error
    >
        No fue posible cargar la informacion del oferente.
    </div>

    <?php // Estado: sin resultados. ?>
    <div
        class="card empty-state d-none"
        data-estado-vacio
    >
        <div class="empty-icon mx-auto">
            <i class="bi bi-search" aria-hidden="true"></i>
        </div>
        <h2 class="h5">Sin resultados</h2>
        <p class="text-secondary mb-0">No se encontro informacion para el oferente solicitado.</p>
    </div>

    <?php // Contenido cuando hay oferente. ?>
    <div class="d-none" data-detalle-contenido>
        <div class="card mb-4">
            <div class="card-body p-4">
                <div class="d-flex flex-column flex-lg-row justify-content-between gap-3">
                    <div>
                        <span class="badge text-bg-secondary mb-2" data-estado></span>
                        <h2 class="h4 mb-1" data-nombre></h2>
                        <p class="text-secondary mb-0">
                            <span data-tipo-identificacion></span>
                            <span aria-hidden="true"> · </span>
                            <span data-identificacion></span>
                        </p>
                    </div>
                    <div class="d-flex flex-column flex-sm-row gap-2 align-items-stretch align-items-sm-start">
                        <a class="btn btn-primary" href="#" data-crear-empleado>
                            <i class="bi bi-person-plus me-1" aria-hidden="true"></i>
                            Crear empleado
                        </a>
                        <a class="btn btn-outline-secondary" href="<?= e(url('index')) ?>">
                            Cancelar
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Informacion personal</div>
                    <div class="card-body">
                        <dl class="row mb-0">
                            <dt class="col-sm-5">Fecha de nacimiento</dt>
                            <dd class="col-sm-7" data-fecha-nacimiento></dd>
                            <dt class="col-sm-5">Direccion</dt>
                            <dd class="col-sm-7 mb-0" data-direccion></dd>
                        </dl>
                    </div>
                </article>
            </div>

            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Informacion de contacto</div>
                    <div class="card-body">
                        <h3 class="h6">Correos</h3>
                        <ul class="mb-3" data-correos></ul>
                        <h3 class="h6">Telefonos</h3>
                        <ul class="mb-0" data-telefonos></ul>
                    </div>
                </article>
            </div>

            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Preparacion academica</div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead>
                                    <tr>
                                        <th scope="col">Institucion</th>
                                        <th scope="col">Titulo</th>
                                        <th scope="col">Periodo</th>
                                    </tr>
                                </thead>
                                <tbody data-preparacion-academica></tbody>
                            </table>
                        </div>
                    </div>
                </article>
            </div>

            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Experiencia laboral</div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead>
                                    <tr>
                                        <th scope="col">Empresa</th>
                                        <th scope="col">Puesto</th>
                                        <th scope="col">Periodo</th>
                                    </tr>
                                </thead>
                                <tbody data-experiencia-laboral></tbody>
                            </table>
                        </div>
                    </div>
                </article>
            </div>

            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Concurso o puesto relacionado</div>
                    <div class="card-body">
                        <dl class="row mb-0">
                            <dt class="col-sm-5">Puesto postulado</dt>
                            <dd class="col-sm-7" data-puesto-postulado></dd>
                            <dt class="col-sm-5">Concurso</dt>
                            <dd class="col-sm-7 mb-0" data-concurso></dd>
                        </dl>
                    </div>
                </article>
            </div>

            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Requisitos cumplidos</div>
                    <div class="card-body">
                        <ul class="mb-0" data-requisitos></ul>
                    </div>
                </article>
            </div>
        </div>
    </div>
</section>
