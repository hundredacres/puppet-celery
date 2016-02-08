# Create celery tasks
define celery::task (
  $target,
  $content,
  $source = undef
) {
  concat::fragment { "${name}_task":
    target  => $target,
    content => $content,
    source  => $source
  }
}
