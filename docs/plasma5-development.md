# Plasma 5 development

## Symlinc issue

Plasma 5 does not reliably detect plasmoids installed through symbolic links
inside ~/.local/share/plasma/plasmoids/.

For development, copy the plasmoid directory instead:

```shell
cp -a \
~/projects/plasma-power-workflow/plasmoid5/org.kde.plasma.lock_logout.workflow \
~/.local/share/plasma/plasmoids/
```

After updates:

```shell
kbuildsycoca5
kquitapp5 plasmashell
plasmashell &
```
