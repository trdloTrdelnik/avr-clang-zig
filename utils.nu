
export def print-and-run-cmd --wrapped [bin, ...args] {
  let cmd = $"($bin) ($args | str join ' ')(ansi reset)"
  print $"(ansi blue)($cmd)"
  ^$bin ...$args
}
