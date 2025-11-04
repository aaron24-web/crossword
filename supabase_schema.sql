-- ============================================
-- ESQUEMA SUPABASE PARA CROSSWORD PUZZLE GAME
-- Adaptado específicamente al proyecto Flutter
-- ============================================

-- NOTA: Este esquema considera:
-- 1. CrosswordPuzzleGame con selectedWords (BuiltList<CrosswordWord>)
-- 2. CrosswordSize enum: small, medium, large, xlarge, xxlarge
-- 3. Serialización de built_value para guardar estado
-- 4. Direction enum: across, down
-- 5. Location con x, y

-- ============================================
-- 1. PERFILES DE USUARIO
-- ============================================
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 2. PROGRESO DEL JUEGO
-- ============================================
-- Guarda el estado completo del CrosswordPuzzleGame
CREATE TABLE game_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Tamaño del puzzle (small, medium, large, xlarge, xxlarge)
  puzzle_size TEXT NOT NULL CHECK (puzzle_size IN ('small', 'medium', 'large', 'xlarge', 'xxlarge')),
  
  -- Crucigrama serializado (Crossword completo con palabras correctas)
  crossword_data JSONB NOT NULL,
  
  -- Palabras alternativas serializadas
  -- Estructura: { "location": { "direction": ["word1", "word2", ...] } }
  alternate_words JSONB NOT NULL,
  
  -- Palabras seleccionadas por el jugador
  -- Estructura: [{ "word": "...", "location": {"x": 0, "y": 0}, "direction": "across" }, ...]
  selected_words JSONB DEFAULT '[]'::jsonb,
  
  -- Metadata
  is_completed BOOLEAN DEFAULT false,
  started_at TIMESTAMP DEFAULT NOW(),
  last_played_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  
  -- Un usuario solo puede tener un progreso por tamaño
  UNIQUE(user_id, puzzle_size)
);

-- Índices para búsquedas rápidas
CREATE INDEX idx_game_progress_user ON game_progress(user_id);
CREATE INDEX idx_game_progress_completed ON game_progress(is_completed);

-- ============================================
-- 3. PUNTUACIONES (LEADERBOARD)
-- ============================================
CREATE TABLE scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  
  -- Tamaño del puzzle
  puzzle_size TEXT NOT NULL CHECK (puzzle_size IN ('small', 'medium', 'large', 'xlarge', 'xxlarge')),
  
  -- Métricas de rendimiento
  time_seconds INTEGER NOT NULL CHECK (time_seconds > 0),
  words_count INTEGER NOT NULL,
  
  -- Timestamp
  completed_at TIMESTAMP DEFAULT NOW()
);

-- Índices para leaderboard
CREATE INDEX idx_scores_leaderboard ON scores(puzzle_size, time_seconds ASC);
CREATE INDEX idx_scores_user ON scores(user_id, completed_at DESC);

-- ============================================
-- 4. CONFIGURACIÓN DE USUARIO
-- ============================================
CREATE TABLE user_settings (
  user_id UUID REFERENCES auth.users(id) PRIMARY KEY ON DELETE CASCADE,
  
  -- Audio settings
  sound_enabled BOOLEAN DEFAULT true,
  music_enabled BOOLEAN DEFAULT true,
  volume DECIMAL(3,2) DEFAULT 0.70 CHECK (volume >= 0 AND volume <= 1),
  
  -- UI preferences
  show_hints BOOLEAN DEFAULT true,
  
  -- Metadata
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 5. LOGROS SIMPLES (OPCIONAL)
-- ============================================
CREATE TABLE achievements (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Logros predefinidos
INSERT INTO achievements (code, name, description) VALUES
  ('first_puzzle', 'Primer Crucigrama', 'Completa tu primer crucigrama'),
  ('speed_demon', 'Demonio de la Velocidad', 'Completa un crucigrama en menos de 5 minutos'),
  ('puzzle_master', 'Maestro de Puzzles', 'Completa 10 crucigramas'),
  ('perfectionist', 'Perfeccionista', 'Completa un crucigrama sin usar hints');

CREATE TABLE user_achievements (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_code TEXT REFERENCES achievements(code),
  unlocked_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, achievement_code)
);

-- ============================================
-- 6. VISTAS ÚTILES
-- ============================================

-- Vista: Leaderboard global por tamaño
CREATE VIEW leaderboard AS
SELECT 
  s.username,
  s.puzzle_size,
  s.time_seconds,
  s.words_count,
  s.completed_at,
  ROW_NUMBER() OVER (PARTITION BY s.puzzle_size ORDER BY s.time_seconds ASC) as rank
FROM scores s
ORDER BY s.puzzle_size, s.time_seconds ASC;

-- Vista: Estadísticas por usuario
CREATE VIEW user_stats AS
SELECT 
  p.id as user_id,
  p.username,
  COUNT(s.id) as total_puzzles_completed,
  AVG(s.time_seconds) as avg_time_seconds,
  MIN(s.time_seconds) as best_time_seconds,
  COUNT(DISTINCT s.puzzle_size) as different_sizes_completed,
  COUNT(ua.achievement_code) as achievements_unlocked
FROM profiles p
LEFT JOIN scores s ON p.id = s.user_id
LEFT JOIN user_achievements ua ON p.id = ua.user_id
GROUP BY p.id, p.username;

-- ============================================
-- 7. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Políticas para PROFILES
CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Políticas para GAME_PROGRESS
CREATE POLICY "Users can view own progress" ON game_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress" ON game_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress" ON game_progress
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own progress" ON game_progress
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para SCORES (públicos para leaderboard)
CREATE POLICY "Anyone can view scores" ON scores
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own scores" ON scores
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para USER_SETTINGS
CREATE POLICY "Users can view own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para USER_ACHIEVEMENTS
CREATE POLICY "Users can view own achievements" ON user_achievements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements" ON user_achievements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 8. FUNCIONES ÚTILES
-- ============================================

-- Función: Actualizar timestamp de last_played_at
CREATE OR REPLACE FUNCTION update_last_played()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_played_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_last_played
  BEFORE UPDATE ON game_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_last_played();

-- Función: Crear configuración por defecto al registrarse
CREATE OR REPLACE FUNCTION create_default_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_default_settings
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_default_settings();

-- Función: Verificar logros al completar puzzle
CREATE OR REPLACE FUNCTION check_achievements()
RETURNS TRIGGER AS $$
DECLARE
  puzzle_count INTEGER;
BEGIN
  -- Logro: Primer puzzle
  IF NOT EXISTS (
    SELECT 1 FROM user_achievements 
    WHERE user_id = NEW.user_id AND achievement_code = 'first_puzzle'
  ) THEN
    INSERT INTO user_achievements (user_id, achievement_code)
    VALUES (NEW.user_id, 'first_puzzle');
  END IF;
  
  -- Logro: Speed demon (menos de 5 minutos = 300 segundos)
  IF NEW.time_seconds < 300 THEN
    INSERT INTO user_achievements (user_id, achievement_code)
    VALUES (NEW.user_id, 'speed_demon')
    ON CONFLICT DO NOTHING;
  END IF;
  
  -- Logro: Puzzle master (10+ puzzles)
  SELECT COUNT(*) INTO puzzle_count
  FROM scores
  WHERE user_id = NEW.user_id;
  
  IF puzzle_count >= 10 THEN
    INSERT INTO user_achievements (user_id, achievement_code)
    VALUES (NEW.user_id, 'puzzle_master')
    ON CONFLICT DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_achievements
  AFTER INSERT ON scores
  FOR EACH ROW
  EXECUTE FUNCTION check_achievements();

-- ============================================
-- 9. ÍNDICES ADICIONALES PARA PERFORMANCE
-- ============================================

CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_game_progress_last_played ON game_progress(last_played_at DESC);
CREATE INDEX idx_scores_completed_at ON scores(completed_at DESC);

-- ============================================
-- NOTAS DE USO EN FLUTTER
-- ============================================

/*
EJEMPLO DE SERIALIZACIÓN EN DART:

1. Guardar progreso:
```dart
final puzzleJson = {
  'crossword_data': serializers.serialize(puzzle.crossword),
  'alternate_words': serializers.serialize(puzzle.alternateWords),
  'selected_words': puzzle.selectedWords.map((w) => {
    'word': w.word,
    'location': {'x': w.location.x, 'y': w.location.y},
    'direction': w.direction.name,
  }).toList(),
};

await supabase.from('game_progress').upsert({
  'user_id': userId,
  'puzzle_size': 'medium',
  ...puzzleJson,
});
```

2. Cargar progreso:
```dart
final data = await supabase
  .from('game_progress')
  .select()
  .eq('user_id', userId)
  .eq('puzzle_size', 'medium')
  .single();

final crossword = serializers.deserialize(data['crossword_data']);
final selectedWords = (data['selected_words'] as List).map((w) => 
  CrosswordWord.word(
    word: w['word'],
    location: Location.at(w['location']['x'], w['location']['y']),
    direction: Direction.values.byName(w['direction']),
  )
).toList();
```

3. Guardar puntuación:
```dart
await supabase.from('scores').insert({
  'user_id': userId,
  'username': username,
  'puzzle_size': 'medium',
  'time_seconds': elapsedSeconds,
  'words_count': puzzle.crossword.words.length,
});
```

4. Obtener leaderboard:
```dart
final leaderboard = await supabase
  .from('leaderboard')
  .select()
  .eq('puzzle_size', 'medium')
  .limit(100);
```
*/
