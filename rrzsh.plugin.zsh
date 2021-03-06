alias 'rn'='R --no-init-file'

rr() {
  if [ $# -eq 0 ]; then; R
  elif [ $1 = "document" ]; then rr_document $@
  elif [ $1 = "test" ]; then rr_test $@
  elif [ $1 = "send" ]; then rr_send $@
  else; Rscript -e $@
  fi
}

rr_document() {
  shift
  if [ $# -eq 0 ]; then; Rscript -e "devtools::document()";
  else; Rscript -e "devtools::document($1)"
  fi
}

rr_test() {
  shift
  if [ $# -eq 0 ]; then; Rscript -e "library(methods); library(devtools); test()";
  else; Rscript -e "library(methods); library(devtools); test($1)"
  fi
}

rr_pull_or_push() {
  if [ $# -eq 2 ]; then
    git $1 -q $2 `git rev-parse --abbrev-ref HEAD`
  else
    git $1 -q origin `git rev-parse --abbrev-ref HEAD`
  fi
}

rr_pull() {
  rr_pull_or_push "pull" $@
}

rr_push() {
  rr_pull_or_push "push" $@ &
}

rr_send() {
  shift
  print "Documenting..."
  rr_document 'shift'
  print "Testing..."
  rr_test 'shift'
  print "Committing..."
  git add "$(git rev-parse --show-toplevel)"
  if [ $# -eq 1 ]; then
   git commit -a -m "$1"
  else
   git commit -a -m "I'm too lazy to write a commit message."
  fi
  print "Pulling..."
  rr_pull
  print "Pushing..."
  rr_push
}
