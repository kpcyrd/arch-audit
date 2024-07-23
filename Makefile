-include Makefile.local

DESTDIR ?=
PREFIX ?= /usr/local
BINDIR ?= ${PREFIX}/bin
DATAROOTDIR ?= ${PREFIX}/share
MANDIR ?= ${DATAROOTDIR}/man
SYSTEMDDIR ?= ${PREFIX}/lib/systemd/system

PROJECT=arch-audit
CARGO_TARGET_DIR ?= target
TARBALLDIR ?= $(CARGO_TARGET_DIR)/release/tarball

RM := rm
CARGO := cargo
SCDOC := scdoc
INSTALL := install
GIT := git
GPG := gpg
SED := sed

DEBUG := 0
ifeq ($(DEBUG), 0)
	CARGO_OPTIONS := --release --locked
	CARGO_TARGET := release
else
	CARGO_OPTIONS :=
	CARGO_TARGET := debug
endif

.PHONY: all arch-audit test docs man completions clean install uninstall

all: arch-audit test docs

arch-audit:
	$(CARGO) build $(CARGO_OPTIONS)

test:
	$(CARGO) test $(CARGO_OPTIONS)

lint:
	$(CARGO) fmt -- --check
	$(CARGO) check
	find . -name '*.rs' -exec touch {} +
	$(CARGO) clippy --all -- -D warnings
	$(CARGO) deny check

docs: man completions

man: contrib/man/arch-audit.1

contrib/man/%.1: contrib/man/%.scd
	$(SCDOC) < $^ > $@

completions: arch-audit
	$(CARGO_TARGET_DIR)/$(CARGO_TARGET)/arch-audit completions bash | $(INSTALL) -Dm 644 /dev/stdin $(CARGO_TARGET_DIR)/completion/bash/arch-audit
	$(CARGO_TARGET_DIR)/$(CARGO_TARGET)/arch-audit completions zsh | $(INSTALL) -Dm 644 /dev/stdin $(CARGO_TARGET_DIR)/completion/zsh/_arch-audit
	$(CARGO_TARGET_DIR)/$(CARGO_TARGET)/arch-audit completions fish | $(INSTALL) -Dm 644 /dev/stdin $(CARGO_TARGET_DIR)/completion/fish/arch-audit.fish

clean:
	$(RM) -rf target contrib/man/*.1

install: arch-audit docs
	$(INSTALL) -Dm 755 $(CARGO_TARGET_DIR)/$(CARGO_TARGET)/arch-audit -t $(DESTDIR)$(BINDIR)
	$(INSTALL) -Dm 644 contrib/man/*.1 -t $(DESTDIR)$(MANDIR)/man1
	$(INSTALL) -Dm 644 $(CARGO_TARGET_DIR)/completion/bash/arch-audit -t $(DESTDIR)$(DATAROOTDIR)/bash-completion/completions
	$(INSTALL) -Dm 644 $(CARGO_TARGET_DIR)/completion/zsh/_arch-audit -t $(DESTDIR)$(DATAROOTDIR)/zsh/site-functions
	$(INSTALL) -Dm 644 $(CARGO_TARGET_DIR)/completion/fish/arch-audit.fish -t $(DESTDIR)$(DATAROOTDIR)/fish/vendor_completions.d
	$(INSTALL) -Dm 644 contrib/systemd/arch-audit.* -t $(DESTDIR)$(SYSTEMDDIR)

uninstall:
	$(RM) -f $(DESTDIR)$(BINDIR)/arch-audit
	$(RM) -f $(DESTDIR)$(MANDIR)/man1/arch-audit.1
	$(RM) -f $(DESTDIR)$(DATAROOTDIR)/bash-completion/completions/arch-audit
	$(RM) -f $(DESTDIR)$(DATAROOTDIR)/zsh/site-functions/_arch-audit
	$(RM) -f $(DESTDIR)$(DATAROOTDIR)/fish/vendor_completions.d/arch-audit.fish

release: all
	$(INSTALL) -d $(TARBALLDIR)
	@glab --version &>/dev/null
	@$(GIT) cliff --strip=all --unreleased
	@$(CARGO) pkgid | $(SED) 's/.*#/current version: /'
	@read -p 'version> ' VERSION && \
		$(SED) -E "s|^version = .*|version = \"$$VERSION\"|" -i Cargo.toml && \
		$(CARGO) build --release && \
		$(GIT) cliff --tag "v$$VERSION" > CHANGELOG.md && \
		$(GIT) commit --gpg-sign --message "chore(release): version v$$VERSION" Cargo.toml Cargo.lock CHANGELOG.md && \
		$(GIT) tag --sign --message "Version v$$VERSION" v$$VERSION && \
		$(GIT) archive --format tar --prefix=$(PROJECT)-v$$VERSION/ v$$VERSION | gzip -cn > $(TARBALLDIR)/$(PROJECT)-v$$VERSION.tar.gz && \
		$(GPG) --detach-sign $(TARBALLDIR)/$(PROJECT)-v$$VERSION.tar.gz && \
		$(GPG) --detach-sign --yes $(CARGO_TARGET_DIR)/release/$(PROJECT) && \
		$(GIT) push --tags origin main && \
		GITLAB_HOST=gitlab.archlinux.org glab release create v$$VERSION $(TARBALLDIR)/$(PROJECT)-v$$VERSION.tar.gz* $(CARGO_TARGET_DIR)/release/$(PROJECT) $(CARGO_TARGET_DIR)/release/$(PROJECT).sig --notes-file <(git cliff --strip=all --latest)
