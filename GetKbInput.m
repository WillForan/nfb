
KbName('UnifyKeyNames');
KbNames = KbName('KeyNames');
EscapeKey = KbName('ESCAPE');
KbReleaseWait;

fprintf(1, '\n*** GetKbInput INFORMATION ***\n');
while 1
    [Pressed, Secs, KeyCode] = KbCheck;
    if Pressed
        if KeyCode(EscapeKey)
            break;
        else
            fprintf(1, '%s\n', KbNames{find(KeyCode)});
            KbReleaseWait;
        end
    end
end
fprintf(1, '\n*** GetKbInput INFORMATION ***\n');
