function [texture, nx, ny] = MakeTextTexture(window, text, bgColor, textFont, textSize, textColor)

    if exist('textFont', 'var') && ~isempty(textFont)
        oldFont = Screen('TextFont', window, textFont);
    end

    if exist('textSize', 'var') && ~isempty(textSize)
        oldTextSize = Screen('TextSize', window, textSize);
    end

    if exist('textColor', 'var') && ~isempty(textColor)
        oldTextColor = Screen('TextColor', window, textColor);
    end

    [~, ~, box] = DrawFormattedText(window, text, 'center', 'center', ...
        textColor);
    textureRect = ones(ceil((box(4) - box(2)) * 1.1), ...
        ceil((box(3) - box(1)) * 1.1)) .* bgColor;
    texture = Screen('MakeTexture', window, textureRect);
    DrawFormattedText(texture, text, 'center', 'center', textColor);
    nx = size(textureRect, 2);
    ny = size(textureRect, 1);
    
    if exist('textFont', 'var') && ~isempty(textFont)
        Screen('TextFont', window, oldFont);
    end

    if exist('textSize', 'var') && ~isempty(textSize)
        Screen('TextSize', window, oldTextSize);
    end

    if exist('textColor', 'var') && ~isempty(textColor)
        Screen('TextColor', window, oldTextColor);
    end
end
